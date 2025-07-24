# frozen_string_literal: true

# logstash-filter-druid-metrics.rb

require 'logstash/filters/base'
require 'logstash/namespace'

module LogStash
  module Filters
    #
    # Base filter to enrich events with druid metrics data
    #
    class DruidMetrics < LogStash::Filters::Base
      config_name 'druid_metrics'

      def register
        # Nothing to register
      end

      def filter(event)
        
        # Convert timestamp to expected format
        if event.get("timestamp")
          time = Time.parse(event.get("timestamp"))
          event.set("timestamp", time.to_i)
        end

        service = event.get("service")
        metric = event.get("metric")

        monitor = nil
        unit = ""

        case service
        when "druid/broker"
          monitor, unit = case metric
            when "query/cache/total/sizeBytes" then ["broker_cache_size", "bytes"]
            when "query/time" then ["broker_query_time", "ms"]
            when "query/bytes" then ["broker_query_return_size", "bytes"]
            when "query/failed/count" then ["broker_failed_query", "event"]
            when "query/timeout/count" then ["broker_timeout_query", "event"]
            when "query/interrupted/count" then ["broker_interrupted_query", "event"]
            when "query/count" then ["broker_query_count", "event"]
            when "query/success/count" then ["broker_query_success", "event"]
            else
              event.cancel
              return
          end
        when "historical"
          monitor, unit = case metric
            when "query/time" then ["historical_query_time", "ms"]
            when "query/segment/time" then ["historical_segmet_time", "ms"]
            when "query/wait/time" then ["historical_wait_time", "ms"]
            when "segment/scan/pending" then ["historical_segment_pending_count", "event"]
            when "query/cpu/time" then ["historical_query_cpu_time", "ms"]
            when "segment/scan/active" then ["historical_segment_count", "event"]
            when "mergeBuffer/pendingRequests" then ["historical_pending_request", "event"]
            when "query/failed/count" then ["historical_failed_query", "event"]
            when "query/timeout/count" then ["historical_timeout_query", "event"]
            when "query/interrupted/count" then ["historical_interrupted_query", "event"]
            when "query/count" then ["historical_query_count", "event"]
            when "query/success/count" then ["historical_query_success", "event"]
            else
              event.cancel
              return
          end
        else
          event.cancel
          return
        end

        if metric == "query/cpu/time"
          value = event.get("value")
          if value.is_a?(Numeric)
            event.set("value", value / 1000.0)  # from microseconds to miliseconds
          end
        end

        event.set("monitor", monitor)
        event.set("unit", unit)
        if event.get("host")
          event.set("sensor_name", event.get("host")[/^[^\.]+/])
        else
          event.set("sensor_name", "N/A")
        end
        event.set("type", "system")

        ["version", "service", "feed", "metric", "host", "success", "hasFilters", "id", "remoteAddress", "duration", "interval", "context", "enableParallelMerge"].each do |field|
          event.remove(field)
        end

        filter_matched(event)
      end
    end
  end
end
