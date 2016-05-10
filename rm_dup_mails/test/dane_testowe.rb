# $Id$

DUPL_MBOX_STR = File.read("DUPL.mbox")
UNIQ_MBOX_STR = File.read("UNIQ.mbox")

DUP_IDS = %w[
  <3F5F019A.1000505@genus.pl>
  <20031206105603.GA13177@amber.localdomain>
]


DUPL_MBOX_ARY = []

dupl_file_names = %w[
  A.mbox
  B.mbox
  C.mbox
  D.mbox
  D.mbox
  A.mbox
  A.mbox
]

dupl_file_names.each do |fname|
  DUPL_MBOX_ARY << File.read(fname)
end


UNIQ_MBOX_ARY = []

uniq_file_names = %w[
  A.mbox
  B.mbox
  C.mbox
  D.mbox
]

uniq_file_names.each do |fname|
  UNIQ_MBOX_ARY << File.read(fname)
end
