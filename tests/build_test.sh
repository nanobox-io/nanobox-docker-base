UUID=$(cat /proc/sys/kernel/random/uuid)
pass "unable to start the container" docker run -d --name $UUID nanobox/base
defer docker kill $UUID

# now we just need to verify that the image is setup correctly

pass [ `ls -lh /home/gonano | head -n 2 | tail -n 1| awk '{print $3}'` == "gonano"]