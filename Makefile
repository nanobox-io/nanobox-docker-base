all: build publish

stability?=latest

login:
	@vagrant ssh -c "docker login"

build:
	@echo "Building 'base' image..."
	@vagrant ssh -c "docker build -t nanobox/base /vagrant"

publish:
	@echo "Tagging 'base' image..."
	@vagrant ssh -c "docker tag -f nanobox/base nanobox/base:${stability}"
	@echo "Publishing 'base:${stability}'..."
	@vagrant ssh -c "docker push nanobox/base:${stability}"

clean:
	@echo "Removing all images..."
	@vagrant ssh -c "docker rmi $(docker images -q)"
