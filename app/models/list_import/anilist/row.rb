class ListImport
  class Anilist
    class Row
      attr_reader :node, :type

      def initialize(node, type)
        @node = node
        @type = type # anime || manga
      end

      def media
        key = "#{type}/#{media_info[:id]}"

        Mapping.lookup('anilist', key) ||
          Mapping.guess(type.classify.safe_constantize, media_info)
      end

      def media_info
        {
          id: node[type]['id'],
          title: node[type]['title_romaji'],
          show_type: node[type]['type'],
          episode_count: node[type]['total_episodes'],
          chapter_count: node[type]['total_chapters']
        }.compact
      end

      def status
        case node['list_status']
        when 'completed' then :completed
        when /ing\z/ then :current
        when /\Aplan/ then :planned
        when 'on-hold' then :on_hold
        when 'dropped' then :dropped
        end
      end

      def progress
        type == 'anime' ? node['episodes_watched'] : node['chapters_read']
      end

      def volumes
        return unless type == 'manga'

        node['volumes_read']
      end

      def rating
        return nil if node['score_raw'].zero?

        # 100-point scale to 5-point scale (raw)
        ((node['score_raw'].to_f / 20) / 0.5).ceil * 0.5
      end

      def reconsume_count
        type == 'anime' ? node['rewatched'] : node['reread']
      end

      def notes
        node['notes']
      end

      def my_start_date
        return nil if node['started_on'].nil?

        date = node['started_on'].split('/')

        Date.strptime(format_date(date), '%F')
      end

      def my_finish_date
        return nil if node['finished_on'].nil?

        date = node['finished_on'].split('/')

        Date.strptime(format_date(date), '%F')
      end

      def data
        %i[status progress rating reconsume_count notes].map { |k|
          [k, send(k)]
        }.to_h
      end

      private

      def format_date(date)
        date[1] ||= '01'
        date[2] ||= '01'
        date.join('-')
      end
    end
  end
end
