From: Kent =?iso-8859-1?Q?Engstr=F6m?= <kent@nsc.liu.se>
Date: Mon, 29 Mar 2010 16:22:12 +0200
Subject: [Lustre-devel] Lustre 1.8.2 client, Text file busy
Message-ID: <m3iq8fus17.fsf@ceres.nsc.liu.se>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

[Cc: to the slurm-dev list as this has been discussed there.]

After an upgrade to Lustre 1.8.2 (patchless client on top of Centos 5.4)
on one of our compute clusters, we have been getting reports of 
spurious "Text file busy" messages.

I have not seen any reports on the Lustre lists about this yet.

A colleague of mine was able to reproduce it reliably, and I've written
a small reproducer script:

$ cat reproducer.sh
#!/bin/sh

rm myscript
cat <<EOF >myscript
#!/bin/sh
echo "running"
EOF
chmod +x myscript

rm mycopy
i=0
while :; do
  i=$(expr $i + 1)
  echo COPY $i
  cp myscript mycopy
  echo RUN $i
  ./mycopy
  sleep 1
done

When I run this on a Lustre filesystem, I invariably get:

$ ./reproducer.sh 
COPY 1
RUN 1
running
COPY 2
RUN 2
./reproducer.sh: ./mycopy: /bin/sh: bad interpreter: Text file busy
COPY 3
RUN 3
running
COPY 4
RUN 4
running
COPY 5
RUN 5
running
COPY 6
RUN 6
running
...

If I insert an "rm mycopy" command before the copy, I get no error.

$ uname -r; rpm -q lustre
2.6.18-164.15.1.el5
lustre-1.8.2-2.6.18_164.15.1.el5_201003191115

(patchless client built from the 1.8.2 source with "make rpms")

The servers for the filesystem are running
"lustre-1.6.7.1-2.6.18_92.1.17.el5_lustre.1.6.7.1smp".

I've tested the same code on another cluster that mounts the same
filesystem. It runs CentOS 4 with patchless client 
lustre-1.6.7.2-2.6.9_89.0.19.ELsmp_201001151307.
The error cannot be reproduced there.

I also expect that there will be no "Text file busy" error when I revert
a node on the first cluster to 1.6.7.1 and run the test script, which I
will proceed to do now.

-- 
Kent Engstr?m, National Supercomputer Centre
kent at nsc.liu.se, +46 13 28 4444
