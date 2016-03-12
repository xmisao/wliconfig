require 'optparse'
require 'yaml'
require 'mechanize'
require 'logger'

$wlog = Logger.new(STDOUT)

module WLIConfig
  #
  # Product classes
  #
  module Product
    #
    # Product class for WLI-UTX-AG300
    #
    class WLI_UTX_AG300
      attr_reader :ip_addr, :username, :password

      def initialize(ip_addr, username, password)
        @ip_addr, @username, @password = ip_addr, username, password
        @url = "http://#{ip_addr}/"
      end

      def change_config(config)
        # print url
        $wlog.info("Attempt to access to '#{@url}'.")

        agent = create_agent()

        # fetch index page
        $wlog.info("Begin fetch index page.")
        page = agent.get(@url)
        page = fetch_main_iframe(page)
        page = page.links_with(:href => 'index.html?page=wizard_func_wlan_sta_crypto.html')[0].click
        $wlog.info("End fetch index page.")

        # fetch config page and submit config
        $wlog.info("Begin fetch config page and submit config.")
        page = fetch_main_iframe(page)
        form = page.forms[0]
        fill_config_form(form, config)
        page = form.submit
        $wlog.info("End fetch ocnfig page and submit config.")

        # fetch finish page
        $wlog.info("Begin fetch complete page.")
        page = page.forms[0].submit
        $wlog.info("End fetch complete page.")
      end

      def create_agent()
        agent = Mechanize.new

        # meta refresh enable
        agent.follow_meta_refresh = true

        # basic auth config for url
        agent.add_auth(@url, @username, @password)

        agent
      end

      def fetch_main_iframe(page)
        # find lower frame and go
        lower = page.frames_with('lower')[0].click

        # find main iframe and go
        lower.iframes_with('main')[0].click
      end

      def fill_config_form(form, config)
        form.ssid = config.ssid
        form.authmode = config.mode 
        form.auth_pass = config.pass
      end
    end
  end

  #
  # Commandline option container
  #
  class Options
    attr_accessor :product, :addr, :user, :pass, :wlan_ssid, :wlan_mode, :wlan_key

    def update_from_file(fname)
      return unless fname
      if FileTest.exist?(fname)
        $wlog.info("Configuration file #{fname} does exist.")
        open(fname){|f|
          yaml = YAML.load(f.read)
          @addr ||= yaml["addr"]
          @user ||= yaml["user"]
          @pass ||= yaml["pass"]
          @wlan_ssid ||= yaml["wlan-ssid"]
          @wlan_mode ||= yaml["wlan-mode"]
          @wlan_key ||= yaml["wlan-key"]
        }
        true
      else
        $wlog.warn("Configuration file #{fname} does not exist.")
        false
      end
    end

    def update_from_map(map)
      @addr = map[:addr] || @addr
      @user = map[:user] || @user
      @pass = map[:pass] || @pass
      @wlan_ssid = map[:wlan_ssid] || @wlan_ssid
      @wlan_mode = map[:wlan_mode] || @wlan_mode
      @wlan_key = map[:wlan_key] || @wlan_key
    end

    def valid?
      [@addr, @user, @pass, @wlan_ssid, @wlan_mode, @wlan_key].count(nil) == 0
    end
  end

  #
  # WLAN configure
  #
  class WLANConfig
    attr_reader :ssid, :mode, :pass

    def initialize(ssid, mode, pass)
      @ssid, @mode, @pass = ssid, mode, pass
    end
  end

  #
  # Create concrete product instance
  #
  class ProductFactory
    include Product

    @@PRODUCT_MAP = {
      "WLI-UTX-AG300" => WLI_UTX_AG300
    }
    @@PRODUCT_MAP.default = WLI_UTX_AG300

    def self.create(product, *params)
      @@PRODUCT_MAP[product].new(*params)
    end
  end

  def create_option_parser(container)
    op = OptionParser.new


    op.banner = "wliconfig -- The 3rd party configuration cli for BUFFALO INC wireless lan adopters are called 'WLI' series.\n\nUsage: wliconfig [options...]"
    op.version = "1.0.0"

    op.on('-f FILE', 'Read options from specified YAML file.'){|v| container[:fname] = v}
    op.on('-a', '--addr ADDR', 'WLI product\'s ip address. (eg. 192.168.0.1)'){|v| container[:addr] = v}
    op.on('-u', '--user USERNAME', 'Basic auth username. (eg. admin)'){|v| container[:user] = v}
    op.on('-p', '--pass PASSWORD', 'Basic auth password. (eg. password)'){|v| container[:pass] = v}
    op.on('-s', '--wlan-ssid SSID', 'SSID that to connect wireless lan.'){|v| container[:wlan_ssid] = v}
    op.on('-m', '--wlan-mode MODE', 'Auth mode that to connect wireless lan. (none, wep_hex, wep_char, tkip, aes, wpa2_tkip or wpa2_aes is valid.)'){|v| container[:wlan_mode] = v}
    op.on('-k', '--wlan-key KEY', 'Key or pass phrase that to connect wireless lan.'){|v| container[:wlan_key] = v}
    op.on('--debug', 'For developers only. Enabled debug mode.'){|v| $debug = true}

    op
  end

  def create_options(container)
    opts = Options.new

    opts.update_from_file("#{ENV['HOME']}/.wliconfig")
    opts.update_from_file(container[:fname])
    opts.update_from_map(container)

    opts
  end

  def main(argv)
    container = {}
    parser = create_option_parser(container)
    parser.parse(argv)

    unless $debug
      $wlog.level = Logger::INFO
      $wlog.formatter = proc{|severity, datetime, progname, msg| "#{msg}\n"}
    end

    $wlog.info("Start processing...")

    $wlog.debug("container:" + container.inspect)

    options = create_options(container)
    $wlog.debug("options:" + options.inspect)

    unless options.valid?
      raise "Some options were not specified. Please read usage 'wliconfig --help'."
    end

    product = ProductFactory.create(options.product, options.addr, options.user, options.pass)
    $wlog.debug("product:" + product.inspect)

    config = WLANConfig.new(options.wlan_ssid, options.wlan_mode, options.wlan_key)
    $wlog.debug("config:" + config.inspect)

    product.change_config(config)

    $wlog.info("Complete processing successfully.")

    return 0
  rescue
    $wlog.error($!)
    $wlog.error("Processing failure.")

    return 1
  end
end
