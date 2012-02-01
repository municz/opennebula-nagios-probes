require 'nagios-probe'

#
class OpenNebulaEconeProbe < Nagios::Probe

  #
  def check_crit
    false
  end

  #
  def check_warn
    false
  end

  #
  def crit_message
    "Things are bad"
  end

  #
  def warn_message
    "Things aren't going well"
  end

  #
  def ok_message
    "Nothing to see here"
  end
end