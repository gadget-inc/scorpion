# frozen_string_literal: true
require "test_helper"

class Infrastructure::UnitOfWorkTest < ActiveSupport::TestCase
  test "no active unit of work by default" do
    assert_nil Infrastructure::UnitOfWork.current
  end

  test "current active unit of work is set inside unit block" do
    called = false
    Infrastructure::UnitOfWork.unit("test") do |unit|
      assert_equal unit, Infrastructure::UnitOfWork.current
      called = true
    end

    assert called
  end

  test "units of work don't nest" do
    called = false
    Infrastructure::UnitOfWork.unit("outer") do |outer|
      Infrastructure::UnitOfWork.unit("inner") do |inner|
        assert_equal outer, Infrastructure::UnitOfWork.current
        assert_equal outer, inner
        called = true
      end
    end

    assert called
  end

  test "units of work call callbacks" do
    called = false
    Infrastructure::UnitOfWork.unit("test") do |_unit|
      Infrastructure::UnitOfWork.on_success do
        called = true
      end
    end

    assert called
  end

  test "units of work have independent callbacks" do
    calls = 0
    Infrastructure::UnitOfWork.unit("test") do |_unit|
      Infrastructure::UnitOfWork.on_success do
        calls += 1
      end
      Infrastructure::UnitOfWork.on_success do
        calls += 1
      end
    end

    Infrastructure::UnitOfWork.unit("test 2") do |_unit|
      Infrastructure::UnitOfWork.on_success do
      end
    end

    assert_equal 2, calls
  end

  test "units of work can have idempotent callbacks" do
    calls = { a: 0, b: 0 }
    Infrastructure::UnitOfWork.unit("test") do |_unit|
      Infrastructure::UnitOfWork.on_success(idempotency_key: :a) do
        calls[:a] += 1
      end
      Infrastructure::UnitOfWork.on_success(idempotency_key: :a) do
        calls[:a] += 1
      end
      Infrastructure::UnitOfWork.on_success(idempotency_key: :a) do
        calls[:a] += 1
      end
      Infrastructure::UnitOfWork.on_success(idempotency_key: :b) do
        calls[:b] += 1
      end
    end

    assert_equal 1, calls[:a]
    assert_equal 1, calls[:b]
  end
end
