# frozen_string_literal: true
require "test_helper"

module Infrastructure
  class UnitOfWorkTest < ActiveSupport::TestCase
    test "no active unit of work by default" do
      assert_nil UnitOfWork.current
    end

    test "current active unit of work is set inside unit block" do
      called = false
      UnitOfWork.unit("test") do |unit|
        assert_equal unit, UnitOfWork.current
        called = true
      end

      assert called
    end

    test "units of work don't nest" do
      called = false
      UnitOfWork.unit("outer") do |outer|
        UnitOfWork.unit("inner") do |inner|
          assert_equal outer, UnitOfWork.current
          assert_equal outer, inner
          called = true
        end
      end

      assert called
    end

    test "units of work call callbacks" do
      called = false
      UnitOfWork.unit("test") do |_unit|
        UnitOfWork.on_success do
          called = true
        end
      end

      assert called
    end

    test "units of work have independent callbacks" do
      calls = 0
      UnitOfWork.unit("test") do |_unit|
        UnitOfWork.on_success do
          calls += 1
        end
        UnitOfWork.on_success do
          calls += 1
        end
      end

      UnitOfWork.unit("test 2") do |_unit|
        UnitOfWork.on_success do
        end
      end

      assert_equal 2, calls
    end

    test "units of work can have idempotent callbacks" do
      calls = { a: 0, b: 0 }
      UnitOfWork.unit("test") do |_unit|
        UnitOfWork.on_success(idempotency_key: :a) do
          calls[:a] += 1
        end
        UnitOfWork.on_success(idempotency_key: :a) do
          calls[:a] += 1
        end
        UnitOfWork.on_success(idempotency_key: :a) do
          calls[:a] += 1
        end
        UnitOfWork.on_success(idempotency_key: :b) do
          calls[:b] += 1
        end
      end

      assert_equal 1, calls[:a]
      assert_equal 1, calls[:b]
    end
  end
end
