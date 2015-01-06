# https://github.com/sole/Tween.js
module Moon
  module Easing
    module Linear
      def self.call(k)
        k
      end
    end

    module QuadraticIn
      def self.call(k)
        k * k
      end
    end

    module QuadraticOut
      def self.call(k)
        k * (2 - k)
      end
    end

    module QuadraticInOut
      def self.call(k)
        if (k *= 2) < 1
          0.5 * k * k
        else
          -0.5 * ((k-=1) * (k - 2) - 1)
        end
      end
    end

    module CubicIn
      def self.call(k)
        k * k * k
      end
    end

    module CubicOut
      def self.call(k)
        (k -= 1) * k * k + 1
      end
    end

    module CubicInOut
      def self.call(k)
        if (k *= 2) < 1
          0.5 * k * k * k
        else
          0.5 * ((k -= 2) * k * k + 2)
        end
      end
    end

    module QuarticIn
      def self.call(k)
        k * k * k * k
      end
    end

    module QuarticOut
      def self.call(k)
        1 - ((k-=1) * k * k * k)
      end
    end

    module QuarticInOut
      def self.call(k)
        if (k *= 2) < 1
          0.5 * k * k * k * k
        else
          -0.5 * ((k -= 2) * k * k * k - 2)
        end
      end
    end

    module QuinticIn
      def self.call(k)
        k * k * k * k * k
      end
    end

    module QuinticOut
      def self.call(k)
        (k-=1) * k * k * k * k + 1
      end
    end

    module QuinticInOut
      def self.call(k)
        if ((k *= 2) < 1)
          0.5 * k * k * k * k * k
        else
          0.5 * ((k -= 2) * k * k * k * k + 2)
        end
      end
    end

    module SinusoidalIn
      def self.call(k)
        1 - Math.cos(k * Math::PI / 2)
      end
    end

    module SinusoidalOut
      def self.call(k)
        Math.sin(k * Math::PI / 2)
      end
    end

    module SinusoidalInOut
      def self.call(k)
        0.5 * (1 - Math.cos(Math::PI * k))
      end
    end

    module ExponentialIn
      def self.call(k)
        k == 0 ? 0 : 1024 ** (k - 1)
      end
    end

    module ExponentialOut
      def self.call(k)
        k == 1 ? 1 : 1 - 2 ** (-10 * k)
      end
    end

    module ExponentialInOut
      def self.call(k)
        if (k == 0)
          0
        elsif (k == 1)
          1
        elsif ((k *= 2) < 1)
          0.5 * 1024 ** (k - 1)
        else
          0.5 * (-(2 ** (-10 * (k - 1))) + 2)
        end
      end
    end

    module CircularIn
      def self.call(k)
        1 - Math.sqrt(1 - k * k)
      end
    end

    module CircularOut
      def self.call(k)
        Math.sqrt(1 - ((k-=1) * k))
      end
    end

    module CircularInOut
      def self.call(k)
        if ((k *= 2) < 1)
          -0.5 * (Math.sqrt(1 - k * k) - 1)
        else
          0.5 * (Math.sqrt(1 - (k -= 2) * k) + 1)
        end
      end
    end

    module ElasticIn
      def self.call(k)
        s = nil
        a = 0.1
        p = 0.4
        if (k == 0)
          0
        elsif (k == 1)
          1
        end
        if (!a || a < 1)
          a = 1
          s = p / 4
        else
          s = p * Math.asin(1 / a) / (2 * Math::PI)
        end
        -(a * (2 ** (10 * (k -= 1))) * Math.sin((k - s) * (2 * Math::PI) / p))
      end
    end

    module ElasticOut
      def self.call(k)
        s = nil
        a = 0.1
        p = 0.4
        if k == 0
          0
        elsif k == 1
          1
        end

        if a == 0 || a < 1
          a = 1
          s = p / 4
        else
          s = p * Math.asin(1 / a) / (2 * Math::PI)
        end
        (a * (2 ** (-10 * k)) * Math.sin((k - s) * (2 * Math::PI) / p) + 1)
      end
    end

    module ElasticInOut
      def self.call(k)
        s = nil
        a = 0.1
        p = 0.4
        if k == 0
          0
        elsif k == 1
          1
        end

        if a == 0 || a < 1
          a = 1
          s = p / 4
        else
          s = p * Math.asin(1 / a) / (2 * Math::PI)
        end
        if (k *= 2) < 1
          -0.5 * (a * (2 ** (10 * (k -= 1))) * Math.sin((k - s) * (2 * Math::PI) / p))
        else
          a * (2 ** (-10 * (k -= 1))) * Math.sin((k - s) * (2 * Math::PI) / p) * 0.5 + 1
        end
      end
    end

    module BackIn
      def self.call(k)
        s = 1.70158
        k * k * ((s + 1) * k - s)
      end
    end

    module BackOut
      def self.call(k)
        s = 1.70158
        (k-=1) * k * ((s + 1) * k + s) + 1;
      end
    end

    module BackInOut
      def self.call(k)
        s = 1.70158 * 1.525;
        if ((k *= 2) < 1)
          0.5 * (k * k * ((s + 1) * k - s))
        else
          0.5 * ((k -= 2) * k * ((s + 1) * k + s) + 2)
        end
      end
    end

    module BounceOut
      def self.call(k)
        if k < (1 / 2.75)
          7.5625 * k * k;
        elsif k < (2 / 2.75)
          7.5625 * (k -= (1.5 / 2.75)) * k + 0.75;
        elsif k < (2.5 / 2.75)
          7.5625 * (k -= (2.25 / 2.75)) * k + 0.9375;
        else
          7.5625 * (k -= (2.625 / 2.75)) * k + 0.984375;
        end
      end
    end

    module BounceIn
      def self.call(k)
        1 - BounceOut.call(1 - k)
      end
    end

    module BounceInOut
      def self.call(k)
        if k < 0.5
          BounceIn.call(k * 2) * 0.5
        else
          BounceOut.call(k * 2 - 1) * 0.5 + 0.5
        end
      end
    end
  end
end
