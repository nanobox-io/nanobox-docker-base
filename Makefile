all: base

base:
ifdef docker_user
	vagrant up && vagrant destroy -f
else
	export docker_user='nanobox' && vagrant up && vagrant destroy -f
endif

publish:
ifdef docker_user
	vagrant provision
else
	export docker_user='nanobox' && vagrant provision
endif

clean:
	vagrant destroy -f
