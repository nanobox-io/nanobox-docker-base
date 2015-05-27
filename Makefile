all: base

base:
	vagrant up && vagrant destroy -f
