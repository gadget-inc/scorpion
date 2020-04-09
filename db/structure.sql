SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: gapfillinternal(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gapfillinternal(s anyelement, v anyelement) RETURNS anyelement
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  RETURN COALESCE(v,s);
END;
$$;


--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


--
-- Name: que_validate_tags(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_validate_tags(tags_array jsonb) RETURNS boolean
    LANGUAGE sql
    AS $$
  SELECT bool_and(
    jsonb_typeof(value) = 'string'
    AND
    char_length(value::text) <= 100
  )
  FROM jsonb_array_elements(tags_array)
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    job_class text NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error_message text,
    queue text DEFAULT 'default'::text NOT NULL,
    last_error_backtrace text,
    finished_at timestamp with time zone,
    expired_at timestamp with time zone,
    args jsonb DEFAULT '[]'::jsonb NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT error_length CHECK (((char_length(last_error_message) <= 500) AND (char_length(last_error_backtrace) <= 10000))),
    CONSTRAINT job_class_length CHECK ((char_length(
CASE job_class
    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN ((args -> 0) ->> 'job_class'::text)
    ELSE job_class
END) <= 200)),
    CONSTRAINT queue_length CHECK ((char_length(queue) <= 100)),
    CONSTRAINT valid_args CHECK ((jsonb_typeof(args) = 'array'::text)),
    CONSTRAINT valid_data CHECK (((jsonb_typeof(data) = 'object'::text) AND ((NOT (data ? 'tags'::text)) OR ((jsonb_typeof((data -> 'tags'::text)) = 'array'::text) AND (jsonb_array_length((data -> 'tags'::text)) <= 5) AND public.que_validate_tags((data -> 'tags'::text))))))
)
WITH (fillfactor='90');


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.que_jobs IS '4';


--
-- Name: que_determine_job_state(public.que_jobs); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_determine_job_state(job public.que_jobs) RETURNS text
    LANGUAGE sql
    AS $$
  SELECT
    CASE
    WHEN job.expired_at  IS NOT NULL    THEN 'expired'
    WHEN job.finished_at IS NOT NULL    THEN 'finished'
    WHEN job.error_count > 0            THEN 'errored'
    WHEN job.run_at > CURRENT_TIMESTAMP THEN 'scheduled'
    ELSE                                     'ready'
    END
$$;


--
-- Name: que_job_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_job_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    locker_pid integer;
    sort_key json;
  BEGIN
    -- Don't do anything if the job is scheduled for a future time.
    IF NEW.run_at IS NOT NULL AND NEW.run_at > now() THEN
      RETURN null;
    END IF;

    -- Pick a locker to notify of the job's insertion, weighted by their number
    -- of workers. Should bounce pseudorandomly between lockers on each
    -- invocation, hence the md5-ordering, but still touch each one equally,
    -- hence the modulo using the job_id.
    SELECT pid
    INTO locker_pid
    FROM (
      SELECT *, last_value(row_number) OVER () + 1 AS count
      FROM (
        SELECT *, row_number() OVER () - 1 AS row_number
        FROM (
          SELECT *
          FROM public.que_lockers ql, generate_series(1, ql.worker_count) AS id
          WHERE listening AND queues @> ARRAY[NEW.queue]
          ORDER BY md5(pid::text || id::text)
        ) t1
      ) t2
    ) t3
    WHERE NEW.id % count = row_number;

    IF locker_pid IS NOT NULL THEN
      -- There's a size limit to what can be broadcast via LISTEN/NOTIFY, so
      -- rather than throw errors when someone enqueues a big job, just
      -- broadcast the most pertinent information, and let the locker query for
      -- the record after it's taken the lock. The worker will have to hit the
      -- DB in order to make sure the job is still visible anyway.
      SELECT row_to_json(t)
      INTO sort_key
      FROM (
        SELECT
          'job_available' AS message_type,
          NEW.queue       AS queue,
          NEW.priority    AS priority,
          NEW.id          AS id,
          -- Make sure we output timestamps as UTC ISO 8601
          to_char(NEW.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at
      ) t;

      PERFORM pg_notify('que_listener_' || locker_pid::text, sort_key::text);
    END IF;

    RETURN null;
  END
$$;


--
-- Name: que_state_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_state_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    row record;
    message json;
    previous_state text;
    current_state text;
  BEGIN
    IF TG_OP = 'INSERT' THEN
      previous_state := 'nonexistent';
      current_state  := public.que_determine_job_state(NEW);
      row            := NEW;
    ELSIF TG_OP = 'DELETE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := 'nonexistent';
      row            := OLD;
    ELSIF TG_OP = 'UPDATE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := public.que_determine_job_state(NEW);

      -- If the state didn't change, short-circuit.
      IF previous_state = current_state THEN
        RETURN null;
      END IF;

      row := NEW;
    ELSE
      RAISE EXCEPTION 'Unrecognized TG_OP: %', TG_OP;
    END IF;

    SELECT row_to_json(t)
    INTO message
    FROM (
      SELECT
        'job_change' AS message_type,
        row.id       AS id,
        row.queue    AS queue,

        coalesce(row.data->'tags', '[]'::jsonb) AS tags,

        to_char(row.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at,
        to_char(now()      AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS time,

        CASE row.job_class
        WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' THEN
          coalesce(
            row.args->0->>'job_class',
            'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'
          )
        ELSE
          row.job_class
        END AS job_class,

        previous_state AS previous_state,
        current_state  AS current_state
    ) t;

    PERFORM pg_notify('que_state', message::text);

    RETURN null;
  END
$$;


--
-- Name: gapfill(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE public.gapfill(anyelement) (
    SFUNC = public.gapfillinternal,
    STYPE = anyelement
);


--
-- Name: account_user_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_user_permissions (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: account_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_user_permissions_id_seq OWNED BY public.account_user_permissions.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    creator_id bigint NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    internal_tags character varying[] DEFAULT '{}'::character varying[] NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: activity_feed_item_subject_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_feed_item_subject_links (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    activity_feed_item_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL
);


--
-- Name: activity_feed_item_subject_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_feed_item_subject_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_feed_item_subject_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_feed_item_subject_links_id_seq OWNED BY public.activity_feed_item_subject_links.id;


--
-- Name: activity_feed_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_feed_items (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    property_id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_at timestamp without time zone NOT NULL,
    group_start timestamp without time zone NOT NULL,
    group_end timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: activity_feed_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_feed_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_feed_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_feed_items_id_seq OWNED BY public.activity_feed_items.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assessment_descriptors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_descriptors (
    id bigint NOT NULL,
    key character varying NOT NULL,
    title character varying NOT NULL,
    severity character varying NOT NULL,
    description character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assessment_descriptors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_descriptors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_descriptors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_descriptors_id_seq OWNED BY public.assessment_descriptors.id;


--
-- Name: assessment_issue_change_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_issue_change_events (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    property_id bigint NOT NULL,
    assessment_issue_id bigint NOT NULL,
    action character varying NOT NULL,
    action_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    assessment_production_group_id bigint
);


--
-- Name: assessment_issue_change_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_issue_change_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_issue_change_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_issue_change_events_id_seq OWNED BY public.assessment_issue_change_events.id;


--
-- Name: assessment_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_issues (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    property_id bigint NOT NULL,
    number integer NOT NULL,
    opened_at timestamp without time zone NOT NULL,
    last_seen_at timestamp without time zone NOT NULL,
    closed_at timestamp without time zone,
    key character varying NOT NULL,
    key_category character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    subject_type character varying,
    subject_id character varying,
    production_scope character varying NOT NULL
);


--
-- Name: assessment_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_issues_id_seq OWNED BY public.assessment_issues.id;


--
-- Name: assessment_production_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_production_groups (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    property_id bigint NOT NULL,
    reason character varying NOT NULL,
    started_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assessment_production_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_production_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_production_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_production_groups_id_seq OWNED BY public.assessment_production_groups.id;


--
-- Name: assessment_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_results (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    property_id bigint NOT NULL,
    assessment_at timestamp without time zone NOT NULL,
    key character varying NOT NULL,
    key_category character varying NOT NULL,
    score integer NOT NULL,
    score_mode character varying NOT NULL,
    error_code character varying,
    url character varying,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    issue_id bigint,
    production_scope character varying NOT NULL,
    subject_type character varying,
    subject_id character varying,
    assessment_production_group_id bigint NOT NULL
);


--
-- Name: assessment_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_results_id_seq OWNED BY public.assessment_results.id;


--
-- Name: crawl_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crawl_attempts (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    property_id bigint NOT NULL,
    started_reason character varying NOT NULL,
    running boolean DEFAULT false NOT NULL,
    succeeded boolean,
    started_at timestamp without time zone,
    last_progress_at timestamp without time zone,
    finished_at timestamp without time zone,
    failure_reason character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    crawl_type character varying NOT NULL
);


--
-- Name: crawl_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crawl_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawl_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crawl_attempts_id_seq OWNED BY public.crawl_attempts.id;


--
-- Name: crawl_test_case_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crawl_test_case_logs (
    id bigint NOT NULL,
    crawl_test_case_id bigint NOT NULL,
    message character varying NOT NULL,
    metadata jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: crawl_test_case_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crawl_test_case_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawl_test_case_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crawl_test_case_logs_id_seq OWNED BY public.crawl_test_case_logs.id;


--
-- Name: crawl_test_cases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crawl_test_cases (
    id bigint NOT NULL,
    crawl_test_run_id bigint NOT NULL,
    property_id bigint NOT NULL,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    running boolean DEFAULT false NOT NULL,
    successful boolean,
    error jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    last_html text
);


--
-- Name: crawl_test_cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crawl_test_cases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawl_test_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crawl_test_cases_id_seq OWNED BY public.crawl_test_cases.id;


--
-- Name: crawl_test_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crawl_test_runs (
    id bigint NOT NULL,
    name character varying NOT NULL,
    endpoint character varying NOT NULL,
    started_by character varying NOT NULL,
    running boolean DEFAULT false NOT NULL,
    successful boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    property_criteria character varying,
    property_limit integer DEFAULT 50 NOT NULL
);


--
-- Name: crawl_test_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crawl_test_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crawl_test_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crawl_test_runs_id_seq OWNED BY public.crawl_test_runs.id;


--
-- Name: flipper_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_features (
    id bigint NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flipper_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_features_id_seq OWNED BY public.flipper_features.id;


--
-- Name: flipper_gates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_gates (
    id bigint NOT NULL,
    feature_key character varying NOT NULL,
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_gates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_gates_id_seq OWNED BY public.flipper_gates.id;


--
-- Name: key_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.key_urls (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    property_id bigint NOT NULL,
    creator_id bigint,
    url character varying NOT NULL,
    page_type character varying NOT NULL,
    creation_reason character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: key_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.key_urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: key_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.key_urls_id_seq OWNED BY public.key_urls.id;


--
-- Name: properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.properties (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    creator_id bigint NOT NULL,
    name character varying NOT NULL,
    crawl_roots character varying[] NOT NULL,
    allowed_domains character varying[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    discarded_at timestamp without time zone,
    ambient boolean DEFAULT false,
    internal_tags character varying[] DEFAULT '{}'::character varying[],
    internal_test_options jsonb
);


--
-- Name: properties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: properties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.properties_id_seq OWNED BY public.properties.id;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.que_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.que_jobs_id_seq OWNED BY public.que_jobs.id;


--
-- Name: que_lockers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.que_lockers (
    pid integer NOT NULL,
    worker_count integer NOT NULL,
    worker_priorities integer[] NOT NULL,
    ruby_pid integer NOT NULL,
    ruby_hostname text NOT NULL,
    queues text[] NOT NULL,
    listening boolean NOT NULL,
    CONSTRAINT valid_queues CHECK (((array_ndims(queues) = 1) AND (array_length(queues, 1) IS NOT NULL))),
    CONSTRAINT valid_worker_priorities CHECK (((array_ndims(worker_priorities) = 1) AND (array_length(worker_priorities, 1) IS NOT NULL)))
);


--
-- Name: que_scheduler_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_scheduler_audit (
    scheduler_job_id bigint NOT NULL,
    executed_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE que_scheduler_audit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.que_scheduler_audit IS '4';


--
-- Name: que_scheduler_audit_enqueued; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_scheduler_audit_enqueued (
    scheduler_job_id bigint NOT NULL,
    job_class character varying(255) NOT NULL,
    queue character varying(255),
    priority integer,
    args jsonb NOT NULL,
    job_id bigint,
    run_at timestamp with time zone
);


--
-- Name: que_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_values (
    key text NOT NULL,
    value jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT valid_value CHECK ((jsonb_typeof(value) = 'object'::text))
)
WITH (fillfactor='90');


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shopify_data_app_store_apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_app_store_apps (
    id bigint NOT NULL,
    title character varying NOT NULL,
    app_store_url character varying NOT NULL,
    app_store_developer_url character varying NOT NULL,
    developer_name character varying NOT NULL,
    category character varying NOT NULL,
    image_url character varying NOT NULL,
    developer_url character varying,
    faq_url character varying,
    inferred_domains character varying[] NOT NULL,
    confirmed_domains character varying[] NOT NULL,
    priority integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopify_data_app_store_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_app_store_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_app_store_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_app_store_apps_id_seq OWNED BY public.shopify_data_app_store_apps.id;


--
-- Name: shopify_data_asset_change_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_asset_change_events (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    shopify_shop_id bigint NOT NULL,
    shopify_data_theme_id bigint NOT NULL,
    key character varying NOT NULL,
    action character varying NOT NULL,
    action_at timestamp without time zone NOT NULL
);


--
-- Name: shopify_data_asset_change_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_asset_change_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_asset_change_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_asset_change_events_id_seq OWNED BY public.shopify_data_asset_change_events.id;


--
-- Name: shopify_data_detected_app_change_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_detected_app_change_events (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    shopify_shop_id bigint NOT NULL,
    shopify_data_detected_app_id bigint NOT NULL,
    action character varying NOT NULL,
    action_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopify_data_detected_app_change_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_detected_app_change_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_detected_app_change_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_detected_app_change_events_id_seq OWNED BY public.shopify_data_detected_app_change_events.id;


--
-- Name: shopify_data_detected_apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_detected_apps (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    shopify_shop_id bigint NOT NULL,
    name character varying NOT NULL,
    first_seen_at timestamp without time zone NOT NULL,
    last_seen_at timestamp without time zone NOT NULL,
    seen_last_time boolean NOT NULL,
    reasons character varying[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    shopify_data_app_store_app_id bigint,
    subject_key character varying NOT NULL
);


--
-- Name: shopify_data_detected_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_detected_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_detected_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_detected_apps_id_seq OWNED BY public.shopify_data_detected_apps.id;


--
-- Name: shopify_data_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_events (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    shopify_shop_id bigint NOT NULL,
    event_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    verb character varying NOT NULL,
    path character varying,
    author character varying,
    body character varying,
    description character varying,
    arguments character varying,
    shopify_created_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopify_data_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_events_id_seq OWNED BY public.shopify_data_events.id;


--
-- Name: shopify_data_shop_change_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_shop_change_events (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    shopify_shop_id bigint NOT NULL,
    record_attribute character varying NOT NULL,
    old_value jsonb,
    new_value jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopify_data_shop_change_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_shop_change_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_shop_change_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_shop_change_events_id_seq OWNED BY public.shopify_data_shop_change_events.id;


--
-- Name: shopify_data_theme_change_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_theme_change_events (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    shopify_shop_id bigint NOT NULL,
    shopify_data_theme_id bigint NOT NULL,
    record_attribute character varying NOT NULL,
    new_value jsonb,
    old_value jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shopify_data_theme_change_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_theme_change_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_theme_change_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_theme_change_events_id_seq OWNED BY public.shopify_data_theme_change_events.id;


--
-- Name: shopify_data_themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_data_themes (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    shopify_shop_id bigint NOT NULL,
    theme_id bigint NOT NULL,
    name character varying NOT NULL,
    role character varying NOT NULL,
    theme_store_id bigint,
    shopify_created_at timestamp without time zone NOT NULL,
    shopify_updated_at timestamp without time zone NOT NULL,
    asset_change_tracker jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    processing boolean,
    previewable boolean
);


--
-- Name: shopify_data_themes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_data_themes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_data_themes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_data_themes_id_seq OWNED BY public.shopify_data_themes.id;


--
-- Name: shopify_shops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shopify_shops (
    id bigint NOT NULL,
    domain character varying NOT NULL,
    api_token character varying NOT NULL,
    property_id bigint NOT NULL,
    account_id bigint NOT NULL,
    creator_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp without time zone,
    myshopify_domain character varying NOT NULL,
    country_code character varying,
    country_name character varying,
    currency character varying,
    timezone character varying,
    customer_email character varying,
    source character varying,
    latitude character varying,
    longitude character varying,
    money_format character varying,
    money_with_currency_format character varying,
    cookie_consent_level character varying,
    password_enabled boolean,
    has_storefront boolean,
    multi_location_enabled boolean,
    setup_required boolean,
    pre_launch_enabled boolean,
    requires_extra_payments_agreement boolean,
    taxes_included boolean,
    tax_shipping boolean,
    enabled_presentment_currencies character varying,
    plan_name character varying DEFAULT 'unknown'::character varying NOT NULL,
    plan_display_name character varying DEFAULT 'unknown'::character varying NOT NULL,
    weight_unit character varying,
    shopify_updated_at timestamp without time zone
);


--
-- Name: shopify_shops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shopify_shops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shopify_shops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shopify_shops_id_seq OWNED BY public.shopify_shops.id;


--
-- Name: user_provider_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_provider_identities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    provider_name character varying NOT NULL,
    provider_id character varying NOT NULL,
    provider_details jsonb DEFAULT '{}'::jsonb NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_provider_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_provider_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_provider_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_provider_identities_id_seq OWNED BY public.user_provider_identities.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    full_name character varying,
    email character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    internal_tags character varying[] DEFAULT '{}'::character varying[] NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: account_user_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.account_user_permissions_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: activity_feed_item_subject_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_item_subject_links ALTER COLUMN id SET DEFAULT nextval('public.activity_feed_item_subject_links_id_seq'::regclass);


--
-- Name: activity_feed_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_items ALTER COLUMN id SET DEFAULT nextval('public.activity_feed_items_id_seq'::regclass);


--
-- Name: assessment_descriptors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_descriptors ALTER COLUMN id SET DEFAULT nextval('public.assessment_descriptors_id_seq'::regclass);


--
-- Name: assessment_issue_change_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issue_change_events ALTER COLUMN id SET DEFAULT nextval('public.assessment_issue_change_events_id_seq'::regclass);


--
-- Name: assessment_issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issues ALTER COLUMN id SET DEFAULT nextval('public.assessment_issues_id_seq'::regclass);


--
-- Name: assessment_production_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_production_groups ALTER COLUMN id SET DEFAULT nextval('public.assessment_production_groups_id_seq'::regclass);


--
-- Name: assessment_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_results ALTER COLUMN id SET DEFAULT nextval('public.assessment_results_id_seq'::regclass);


--
-- Name: crawl_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_attempts ALTER COLUMN id SET DEFAULT nextval('public.crawl_attempts_id_seq'::regclass);


--
-- Name: crawl_test_case_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_case_logs ALTER COLUMN id SET DEFAULT nextval('public.crawl_test_case_logs_id_seq'::regclass);


--
-- Name: crawl_test_cases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_cases ALTER COLUMN id SET DEFAULT nextval('public.crawl_test_cases_id_seq'::regclass);


--
-- Name: crawl_test_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_runs ALTER COLUMN id SET DEFAULT nextval('public.crawl_test_runs_id_seq'::regclass);


--
-- Name: flipper_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features ALTER COLUMN id SET DEFAULT nextval('public.flipper_features_id_seq'::regclass);


--
-- Name: flipper_gates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates ALTER COLUMN id SET DEFAULT nextval('public.flipper_gates_id_seq'::regclass);


--
-- Name: key_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_urls ALTER COLUMN id SET DEFAULT nextval('public.key_urls_id_seq'::regclass);


--
-- Name: properties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties ALTER COLUMN id SET DEFAULT nextval('public.properties_id_seq'::regclass);


--
-- Name: que_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs ALTER COLUMN id SET DEFAULT nextval('public.que_jobs_id_seq'::regclass);


--
-- Name: shopify_data_app_store_apps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_app_store_apps ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_app_store_apps_id_seq'::regclass);


--
-- Name: shopify_data_asset_change_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_asset_change_events ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_asset_change_events_id_seq'::regclass);


--
-- Name: shopify_data_detected_app_change_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_app_change_events ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_detected_app_change_events_id_seq'::regclass);


--
-- Name: shopify_data_detected_apps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_apps ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_detected_apps_id_seq'::regclass);


--
-- Name: shopify_data_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_events ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_events_id_seq'::regclass);


--
-- Name: shopify_data_shop_change_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_shop_change_events ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_shop_change_events_id_seq'::regclass);


--
-- Name: shopify_data_theme_change_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_theme_change_events ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_theme_change_events_id_seq'::regclass);


--
-- Name: shopify_data_themes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_themes ALTER COLUMN id SET DEFAULT nextval('public.shopify_data_themes_id_seq'::regclass);


--
-- Name: shopify_shops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_shops ALTER COLUMN id SET DEFAULT nextval('public.shopify_shops_id_seq'::regclass);


--
-- Name: user_provider_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_provider_identities ALTER COLUMN id SET DEFAULT nextval('public.user_provider_identities_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: account_user_permissions account_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_user_permissions
    ADD CONSTRAINT account_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: activity_feed_item_subject_links activity_feed_item_subject_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_item_subject_links
    ADD CONSTRAINT activity_feed_item_subject_links_pkey PRIMARY KEY (id);


--
-- Name: activity_feed_items activity_feed_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_items
    ADD CONSTRAINT activity_feed_items_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assessment_descriptors assessment_descriptors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_descriptors
    ADD CONSTRAINT assessment_descriptors_pkey PRIMARY KEY (id);


--
-- Name: assessment_issue_change_events assessment_issue_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issue_change_events
    ADD CONSTRAINT assessment_issue_change_events_pkey PRIMARY KEY (id);


--
-- Name: assessment_issues assessment_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issues
    ADD CONSTRAINT assessment_issues_pkey PRIMARY KEY (id);


--
-- Name: assessment_production_groups assessment_production_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_production_groups
    ADD CONSTRAINT assessment_production_groups_pkey PRIMARY KEY (id);


--
-- Name: assessment_results assessment_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_results
    ADD CONSTRAINT assessment_results_pkey PRIMARY KEY (id);


--
-- Name: crawl_attempts crawl_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_attempts
    ADD CONSTRAINT crawl_attempts_pkey PRIMARY KEY (id);


--
-- Name: crawl_test_case_logs crawl_test_case_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_case_logs
    ADD CONSTRAINT crawl_test_case_logs_pkey PRIMARY KEY (id);


--
-- Name: crawl_test_cases crawl_test_cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_cases
    ADD CONSTRAINT crawl_test_cases_pkey PRIMARY KEY (id);


--
-- Name: crawl_test_runs crawl_test_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_runs
    ADD CONSTRAINT crawl_test_runs_pkey PRIMARY KEY (id);


--
-- Name: flipper_features flipper_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features
    ADD CONSTRAINT flipper_features_pkey PRIMARY KEY (id);


--
-- Name: flipper_gates flipper_gates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates
    ADD CONSTRAINT flipper_gates_pkey PRIMARY KEY (id);


--
-- Name: key_urls key_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_urls
    ADD CONSTRAINT key_urls_pkey PRIMARY KEY (id);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (id);


--
-- Name: que_lockers que_lockers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_lockers
    ADD CONSTRAINT que_lockers_pkey PRIMARY KEY (pid);


--
-- Name: que_scheduler_audit que_scheduler_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_scheduler_audit
    ADD CONSTRAINT que_scheduler_audit_pkey PRIMARY KEY (scheduler_job_id);


--
-- Name: que_values que_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_values
    ADD CONSTRAINT que_values_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shopify_data_app_store_apps shopify_data_app_store_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_app_store_apps
    ADD CONSTRAINT shopify_data_app_store_apps_pkey PRIMARY KEY (id);


--
-- Name: shopify_data_asset_change_events shopify_data_asset_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_asset_change_events
    ADD CONSTRAINT shopify_data_asset_change_events_pkey PRIMARY KEY (id);


--
-- Name: shopify_data_detected_app_change_events shopify_data_detected_app_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_app_change_events
    ADD CONSTRAINT shopify_data_detected_app_change_events_pkey PRIMARY KEY (id);


--
-- Name: shopify_data_detected_apps shopify_data_detected_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_apps
    ADD CONSTRAINT shopify_data_detected_apps_pkey PRIMARY KEY (id);


--
-- Name: shopify_data_events shopify_data_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_events
    ADD CONSTRAINT shopify_data_events_pkey PRIMARY KEY (id);


--
-- Name: shopify_data_shop_change_events shopify_data_shop_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_shop_change_events
    ADD CONSTRAINT shopify_data_shop_change_events_pkey PRIMARY KEY (id);


--
-- Name: shopify_data_theme_change_events shopify_data_theme_change_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_theme_change_events
    ADD CONSTRAINT shopify_data_theme_change_events_pkey PRIMARY KEY (id);


--
-- Name: shopify_data_themes shopify_data_themes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_themes
    ADD CONSTRAINT shopify_data_themes_pkey PRIMARY KEY (id);


--
-- Name: shopify_shops shopify_shops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_shops
    ADD CONSTRAINT shopify_shops_pkey PRIMARY KEY (id);


--
-- Name: user_provider_identities user_provider_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_provider_identities
    ADD CONSTRAINT user_provider_identities_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: existing_issue_cache_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX existing_issue_cache_lookup ON public.assessment_issues USING btree (account_id, property_id, production_scope, closed_at);


--
-- Name: existing_issue_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX existing_issue_lookup ON public.assessment_issues USING btree (account_id, property_id, key, key_category, closed_at, subject_type, subject_id);


--
-- Name: idx_feed_time_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_feed_time_lookup ON public.activity_feed_items USING btree (account_id, property_id, item_at);


--
-- Name: idx_identity_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_identity_lookup ON public.user_provider_identities USING btree (discarded_at, provider_name, provider_id);


--
-- Name: idx_theme_changes_cursor_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_theme_changes_cursor_lookup ON public.shopify_data_theme_change_events USING btree (account_id, shopify_shop_id, created_at);


--
-- Name: index_accounts_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_discarded_at ON public.accounts USING btree (discarded_at);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_assessment_descriptors_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assessment_descriptors_on_key ON public.assessment_descriptors USING btree (key);


--
-- Name: index_assessment_issues_on_account_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assessment_issues_on_account_id_and_number ON public.assessment_issues USING btree (account_id, number);


--
-- Name: index_crawl_attempts_on_success_and_finished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_crawl_attempts_on_success_and_finished ON public.crawl_attempts USING btree (property_id, crawl_type, succeeded, finished_at);


--
-- Name: index_crawl_test_cases_on_property_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_crawl_test_cases_on_property_id ON public.crawl_test_cases USING btree (property_id);


--
-- Name: index_flipper_features_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_features_on_key ON public.flipper_features USING btree (key);


--
-- Name: index_flipper_gates_on_feature_key_and_key_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_gates_on_feature_key_and_key_and_value ON public.flipper_gates USING btree (feature_key, key, value);


--
-- Name: index_que_scheduler_audit_on_scheduler_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_que_scheduler_audit_on_scheduler_job_id ON public.que_scheduler_audit USING btree (scheduler_job_id);


--
-- Name: index_shopify_data_app_store_apps_on_app_store_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_shopify_data_app_store_apps_on_app_store_url ON public.shopify_data_app_store_apps USING btree (app_store_url);


--
-- Name: index_shopify_data_events_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_shopify_data_events_on_event_id ON public.shopify_data_events USING btree (event_id);


--
-- Name: index_shopify_shops_on_discarded_at_and_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shopify_shops_on_discarded_at_and_domain ON public.shopify_shops USING btree (discarded_at, domain);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: que_jobs_args_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_args_gin_idx ON public.que_jobs USING gin (args jsonb_path_ops);


--
-- Name: que_jobs_data_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_data_gin_idx ON public.que_jobs USING gin (data jsonb_path_ops);


--
-- Name: que_poll_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_poll_idx ON public.que_jobs USING btree (queue, priority, run_at, id) WHERE ((finished_at IS NULL) AND (expired_at IS NULL));


--
-- Name: que_scheduler_audit_enqueued_args; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_scheduler_audit_enqueued_args ON public.que_scheduler_audit_enqueued USING btree (args);


--
-- Name: que_scheduler_audit_enqueued_job_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_scheduler_audit_enqueued_job_class ON public.que_scheduler_audit_enqueued USING btree (job_class);


--
-- Name: que_scheduler_audit_enqueued_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_scheduler_audit_enqueued_job_id ON public.que_scheduler_audit_enqueued USING btree (job_id);


--
-- Name: que_jobs que_job_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_job_notify AFTER INSERT ON public.que_jobs FOR EACH ROW EXECUTE PROCEDURE public.que_job_notify();


--
-- Name: que_jobs que_state_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_state_notify AFTER INSERT OR DELETE OR UPDATE ON public.que_jobs FOR EACH ROW EXECUTE PROCEDURE public.que_state_notify();


--
-- Name: crawl_test_case_logs fk_rails_037f41b748; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_case_logs
    ADD CONSTRAINT fk_rails_037f41b748 FOREIGN KEY (crawl_test_case_id) REFERENCES public.crawl_test_cases(id);


--
-- Name: shopify_data_detected_app_change_events fk_rails_061882a92b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_app_change_events
    ADD CONSTRAINT fk_rails_061882a92b FOREIGN KEY (shopify_shop_id) REFERENCES public.shopify_shops(id);


--
-- Name: activity_feed_item_subject_links fk_rails_0a479440b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_item_subject_links
    ADD CONSTRAINT fk_rails_0a479440b4 FOREIGN KEY (activity_feed_item_id) REFERENCES public.activity_feed_items(id);


--
-- Name: assessment_results fk_rails_121c3ae9d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_results
    ADD CONSTRAINT fk_rails_121c3ae9d1 FOREIGN KEY (issue_id) REFERENCES public.assessment_issues(id);


--
-- Name: shopify_data_asset_change_events fk_rails_170f55912b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_asset_change_events
    ADD CONSTRAINT fk_rails_170f55912b FOREIGN KEY (shopify_data_theme_id) REFERENCES public.shopify_data_themes(id);


--
-- Name: assessment_issue_change_events fk_rails_1f2d50c62a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issue_change_events
    ADD CONSTRAINT fk_rails_1f2d50c62a FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: shopify_shops fk_rails_24f3150cd2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_shops
    ADD CONSTRAINT fk_rails_24f3150cd2 FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: shopify_data_detected_app_change_events fk_rails_2fde6ba7df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_app_change_events
    ADD CONSTRAINT fk_rails_2fde6ba7df FOREIGN KEY (shopify_data_detected_app_id) REFERENCES public.shopify_data_detected_apps(id);


--
-- Name: assessment_results fk_rails_3425d80d39; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_results
    ADD CONSTRAINT fk_rails_3425d80d39 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: crawl_test_cases fk_rails_3aed4e771e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_test_cases
    ADD CONSTRAINT fk_rails_3aed4e771e FOREIGN KEY (crawl_test_run_id) REFERENCES public.crawl_test_runs(id);


--
-- Name: assessment_issues fk_rails_451f31d5b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issues
    ADD CONSTRAINT fk_rails_451f31d5b3 FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: shopify_shops fk_rails_484f3cc7d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_shops
    ADD CONSTRAINT fk_rails_484f3cc7d7 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: shopify_data_theme_change_events fk_rails_4fcb6b6291; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_theme_change_events
    ADD CONSTRAINT fk_rails_4fcb6b6291 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: assessment_issues fk_rails_51b210a22a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issues
    ADD CONSTRAINT fk_rails_51b210a22a FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: shopify_shops fk_rails_55ea274344; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_shops
    ADD CONSTRAINT fk_rails_55ea274344 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: shopify_data_theme_change_events fk_rails_58f303623f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_theme_change_events
    ADD CONSTRAINT fk_rails_58f303623f FOREIGN KEY (shopify_shop_id) REFERENCES public.shopify_shops(id);


--
-- Name: assessment_issue_change_events fk_rails_5aaa2e2fc7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issue_change_events
    ADD CONSTRAINT fk_rails_5aaa2e2fc7 FOREIGN KEY (assessment_issue_id) REFERENCES public.assessment_issues(id);


--
-- Name: shopify_data_detected_app_change_events fk_rails_5bfbbe208d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_app_change_events
    ADD CONSTRAINT fk_rails_5bfbbe208d FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: account_user_permissions fk_rails_5c34e80f82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_user_permissions
    ADD CONSTRAINT fk_rails_5c34e80f82 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: account_user_permissions fk_rails_63fd5df246; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_user_permissions
    ADD CONSTRAINT fk_rails_63fd5df246 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: activity_feed_item_subject_links fk_rails_6a78a164ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_item_subject_links
    ADD CONSTRAINT fk_rails_6a78a164ee FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: properties fk_rails_6ddefd0639; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT fk_rails_6ddefd0639 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: shopify_data_shop_change_events fk_rails_6ebe32fa34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_shop_change_events
    ADD CONSTRAINT fk_rails_6ebe32fa34 FOREIGN KEY (shopify_shop_id) REFERENCES public.shopify_shops(id);


--
-- Name: shopify_data_themes fk_rails_7b8a247913; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_themes
    ADD CONSTRAINT fk_rails_7b8a247913 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: key_urls fk_rails_7ba2bdd466; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_urls
    ADD CONSTRAINT fk_rails_7ba2bdd466 FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: shopify_data_events fk_rails_7d54c4df71; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_events
    ADD CONSTRAINT fk_rails_7d54c4df71 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: key_urls fk_rails_8ca3965867; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_urls
    ADD CONSTRAINT fk_rails_8ca3965867 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: key_urls fk_rails_8e5b672136; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.key_urls
    ADD CONSTRAINT fk_rails_8e5b672136 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: crawl_attempts fk_rails_93ab1bfe63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_attempts
    ADD CONSTRAINT fk_rails_93ab1bfe63 FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: shopify_data_asset_change_events fk_rails_94e7031da0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_asset_change_events
    ADD CONSTRAINT fk_rails_94e7031da0 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: shopify_data_events fk_rails_a18d4c7a4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_events
    ADD CONSTRAINT fk_rails_a18d4c7a4f FOREIGN KEY (shopify_shop_id) REFERENCES public.shopify_shops(id);


--
-- Name: assessment_results fk_rails_a301a83463; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_results
    ADD CONSTRAINT fk_rails_a301a83463 FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: assessment_results fk_rails_a5722821f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_results
    ADD CONSTRAINT fk_rails_a5722821f7 FOREIGN KEY (assessment_production_group_id) REFERENCES public.assessment_production_groups(id);


--
-- Name: activity_feed_items fk_rails_a5b0803240; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_items
    ADD CONSTRAINT fk_rails_a5b0803240 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: shopify_data_detected_apps fk_rails_a9e68aff34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_apps
    ADD CONSTRAINT fk_rails_a9e68aff34 FOREIGN KEY (shopify_data_app_store_app_id) REFERENCES public.shopify_data_app_store_apps(id);


--
-- Name: assessment_production_groups fk_rails_abdc9b0b01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_production_groups
    ADD CONSTRAINT fk_rails_abdc9b0b01 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: assessment_production_groups fk_rails_b7b0a0de98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_production_groups
    ADD CONSTRAINT fk_rails_b7b0a0de98 FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: shopify_data_asset_change_events fk_rails_b95a651ac0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_asset_change_events
    ADD CONSTRAINT fk_rails_b95a651ac0 FOREIGN KEY (shopify_shop_id) REFERENCES public.shopify_shops(id);


--
-- Name: shopify_data_detected_apps fk_rails_be8152b8c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_apps
    ADD CONSTRAINT fk_rails_be8152b8c5 FOREIGN KEY (shopify_shop_id) REFERENCES public.shopify_shops(id);


--
-- Name: assessment_issues fk_rails_c08ec361a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issues
    ADD CONSTRAINT fk_rails_c08ec361a7 FOREIGN KEY (key) REFERENCES public.assessment_descriptors(key);


--
-- Name: accounts fk_rails_c0b1e2d9f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_c0b1e2d9f4 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: shopify_data_shop_change_events fk_rails_c1532a5a76; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_shop_change_events
    ADD CONSTRAINT fk_rails_c1532a5a76 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: shopify_data_theme_change_events fk_rails_cae8a8e7c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_theme_change_events
    ADD CONSTRAINT fk_rails_cae8a8e7c5 FOREIGN KEY (shopify_data_theme_id) REFERENCES public.shopify_data_themes(id);


--
-- Name: user_provider_identities fk_rails_d0ae084ed3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_provider_identities
    ADD CONSTRAINT fk_rails_d0ae084ed3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: assessment_issue_change_events fk_rails_d3313b5120; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issue_change_events
    ADD CONSTRAINT fk_rails_d3313b5120 FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: assessment_issue_change_events fk_rails_db4083ecaa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_issue_change_events
    ADD CONSTRAINT fk_rails_db4083ecaa FOREIGN KEY (assessment_production_group_id) REFERENCES public.assessment_production_groups(id);


--
-- Name: shopify_data_themes fk_rails_f0bb1ceed4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_themes
    ADD CONSTRAINT fk_rails_f0bb1ceed4 FOREIGN KEY (shopify_shop_id) REFERENCES public.shopify_shops(id);


--
-- Name: activity_feed_items fk_rails_f2fd5f3d4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_feed_items
    ADD CONSTRAINT fk_rails_f2fd5f3d4f FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: crawl_attempts fk_rails_fa7728ded8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crawl_attempts
    ADD CONSTRAINT fk_rails_fa7728ded8 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: shopify_data_detected_apps fk_rails_fc0b899b55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shopify_data_detected_apps
    ADD CONSTRAINT fk_rails_fc0b899b55 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: properties fk_rails_ff1cc2f1bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT fk_rails_ff1cc2f1bd FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: que_scheduler_audit_enqueued que_scheduler_audit_enqueued_scheduler_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_scheduler_audit_enqueued
    ADD CONSTRAINT que_scheduler_audit_enqueued_scheduler_job_id_fkey FOREIGN KEY (scheduler_job_id) REFERENCES public.que_scheduler_audit(scheduler_job_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190117141829'),
('20190203190640'),
('20190203192200'),
('20190424181240'),
('20190626154336'),
('20190705135949'),
('20190705140825'),
('20190709141711'),
('20190717223839'),
('20191005201916'),
('20191009141154'),
('20191115002426'),
('20191115143608'),
('20191115145123'),
('20191120173522'),
('20191128164154'),
('20191128165018'),
('20200110170018'),
('20200113162215'),
('20200117184240'),
('20200117224731'),
('20200117225107'),
('20200203221825'),
('20200203221906'),
('20200204015906'),
('20200204154329'),
('20200204154515'),
('20200210194743'),
('20200210202750'),
('20200213161513'),
('20200220191400'),
('20200224224023'),
('20200224225719'),
('20200302134427'),
('20200302135549'),
('20200302153310'),
('20200302194320'),
('20200302205817'),
('20200302233227'),
('20200302234933'),
('20200303162726'),
('20200303162955'),
('20200303203040'),
('20200303213348'),
('20200303213840'),
('20200303215736'),
('20200303221947'),
('20200305154938'),
('20200305185335'),
('20200306143046'),
('20200306163244'),
('20200306213109'),
('20200306214602'),
('20200309180051'),
('20200311152459'),
('20200311152649'),
('20200312162431'),
('20200313150053'),
('20200313152518'),
('20200316160005'),
('20200316215357'),
('20200316222149'),
('20200318181025'),
('20200318181110'),
('20200318202850'),
('20200318214809'),
('20200323141240'),
('20200323141425'),
('20200323141426'),
('20200325165202'),
('20200326174413'),
('20200326175003'),
('20200407181932'),
('20200409162659'),
('20200409170934'),
('20200409182843');


