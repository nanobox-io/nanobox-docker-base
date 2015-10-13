UUID=$(cat /proc/sys/kernel/random/uuid)
pass "unable to start thecontainer" docker run --privileged=true -d --name $UUID nanobox/nanobox-docker-postgresql:$VERSION
defer docker kill $UUID

# now we just need to verify that the image is setup correctly