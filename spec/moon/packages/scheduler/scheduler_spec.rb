require 'spec_helper'
require 'scheduler/scheduler'

describe Moon::Scheduler do
  context '#initialize' do
    scheduler = described_class.new
  end

  context 'Job Management' do
    it 'can add new jobs' do
      s = subject
      n = []
      a = s.every '1s' do
        n << 1
      end
      a.tag('interval')

      b = s.in '2s' do
        n << 2
      end
      b.tag('timeout')

      c = s.run_for '4s' do
        n << 4
      end
      c.tag('timed_process')

      cc = s.run_for '2s' do
        n << 44
      end
      cc.tag('timed_process_allowed_to_timeout')

      d = s.run do
        n << 8
      end
      d.tag('process')

      e = s.run { n << 1 }
      e.tag('process', 'to_remove_by_id')

      s.update(0.16)
      expect(a).not_to be_done
      expect(b).not_to be_done
      expect(c).not_to be_done
      expect(d).not_to be_done

      s.update(1)
      expect(a).not_to be_done
      expect(b).not_to be_done
      expect(c).not_to be_done
      expect(d).not_to be_done

      expect(s.remove(a)).to eq(a)

      s.update(1)
      expect(b).to be_done
      expect(c).not_to be_done
      expect(d).not_to be_done

      s.update(1)

      s.remove_by_tags('timed_process')
      expect(s.jobs).not_to include(c)
      expect(s.jobs).to include(d)

      s.remove_by_id(e.id)
      expect(s.jobs).not_to include(e)

      s.kill
      expect(d).to be_done

      s.clear

      expect(s).to be_asleep
    end
  end
end
