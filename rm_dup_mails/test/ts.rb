# $Id$

Dir.glob("tc_*").sort.each do |filename|
  require filename
end
