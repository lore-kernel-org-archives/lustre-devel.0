From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 17 Nov 2015 00:06:45 +0000
Subject: [lustre-devel] First draft on how to setup lustre client for
	testing.
Message-ID: <8b5ac88cc5bc4127a558fb0e3e83fda9@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Here is a basic tutorial for people looking to test the upstream Lustre
client.

For the latest Lustre client code you needs to checkout the staging-next
branch of the staging tree. The below commands will download the kernel
tree containing the lustre source code of interest. This branch of the
staging tree is what should be used to create Lustre patches for
submission.

git clone git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging.git
git checkout origin/staging-next -b staging-next

Once the tree is checked out you need to configure the Lustre client using
the standard make config or menuconfig depending on your preference. You
will find the Lustre client option in the Staging drivers section since it
is still a work in progress.
make config

Device Drivers -> Staging drivers

Enable the option "Lustre file system support"

Once you enable the Lustre client new options will appear.

<M>   Lustre file system client support
(8192) Lustre obd max ioctl buffer bytes (default 8KB) (NEW)
[ ]   Enable Lustre DEBUG checks (NEW)
<M>     Lustre virtual block device (NEW)
-M-     Lustre networking subsystem
(1048576) Lustre lnet max transfer payload (default 2MB) (NEW)
< >   Lustre networking self testing (NEW)
<M>   LNET infiniband support (NEW)

The Lustre networking subsystem or LNet is the lowest layer of the Lustre
filesystem. It was designed with the idea to allow network traffic to flow
without concern for the under lying hardware. In a typical Lustre file
system setup you have clients, routers, and a server backend.

  ------------       ----------      ----------
  |  client  |  -->  | router |  --> | server |
  ------------       ----------      ----------

For routers all that is needed is just the LNet layer. Currently the upstream
client in not able to build stand alone LNet but that will change in the near
future. One of the options you can change is the LNet transfer payload size.
This allows you control the size of the largest packet that can be transmitted.
Normally 1 MB is the default size. By default LNet will build with support for
TCP/IP sockets. Additionally you can enable support for infiniband hardware usage
with LNet if you have the hardware. The other option if interest to the user
is Lustre networking self testing. When starting LNet default options will be
used to tune your setup. Those options often are not best a specific setup. This
is were the LNet self testing comes in. Using a special userland utility that
communicates with LNet selftest you can analysis the performance you are getting
out the LNet layer and adjust the tunables to meet your needs. Please be aware
routers are not a requirement. The most simple setup you can have is a straight
client to server connection.

The rest of the options deal with Lustre itself. You can control the size of the
data that is allowed over an ioctl. Just leave it at 8K. If you run into problems
testing the client you can enable the DEBUG checks. Lastly is the virtual block
device that allows lustre to mount as a loop back device.

Once you have built your Lustre client now you will need tools to actually use it.
You will need to checkout the Intel lustre repository to obtain the source for
these tools. The following command will obtain the needed source code.

git clone git://git.hpdd.intel.com/fs/lustre-release

After you download the code you will need to apply the following patch so the
tools can use sysfs as well as procfs. Currently the tools only support procfs
by default. Grab the patch from http://review.whamcloud.com/#/c/14675 and
just do a git apply of the patch from the top of the source tree. Once you have
patched your tree run the following commands.

cd lustre-release
sh ./autogen.sh
./configure --disable-server

For RHEL based systems run

make rpms

The completed rpms will be in the top directory of the source tree. Of the rpms
only lustre-client-2.X.Y-***.rpm and lustre-client-tests-2.X.Y-***.rpm are of
interest. The lustre-client-2.X.Y-***.rpm contains all the userland tools and
libraries needed to manage a lustre file system. The lustre-client-tests-***.rpm
contains a test suite that can be used to validate the file system on many levels.
To use this you need to setup a complete file system and configure the test suite
for your particular setup. If you are interested in creating a setup please contact
the lustre-devel at lustre.org mailing list and some one will gladly help you out.

For Debian/Ubuntu systems run

make debs

The finished debian will be in the lustre-release/debs directory. The packages of
interest are:

lustre-dev_2.X.Y-1_**.deb
lustre-utils_2.X.Y-1_***.deb
lustre-tests_2.X.Y-1_***.deb

Just like in the case of rpms the lustre-tests-*.deb is for indepth lustre file system
testing which requires a complex setup. Please contact lustre-devel at lustre.org if
you are interested in such testing.

For both cases for debs and rpms you will need to install them with no dependencies
since the lustre utility tree is undergoing a transition to be used with the upstream
client which means the packages have dependencies not needed.

Once very thing is installed in your nodes and rebooted how you bring things up depends
if it is a router or client. If you bring up a client and have a backend server setup
you can easily mount your lustre filesystem with a command similar to:

mount -t lustre -o "msg_server_address"@tcp:/myfilesystem /filesystem/path

This will automatically setup everything for you.

For the case of routers you just need to bring up the LNet layer. Also if you are only
interested in LNet level testing this also applies for any nodes. For the routers the
commands to bring up LNet are as follows:

modprobe lnet
lctl net up

You should see "LNET configured". At this point LNet is up and running. You can
further validate that LNet is up by issuing the command 'lctl list_nids'. This
will list your local LNet setup. Normally something like the following appears:
10.0.0.20 at tcp. To test if you can reach a remote node just run for example:

lctl ping 10.0.0.3 at tcp

With a LNet set up you can either try out LNet selftest to simulate traffic between
any nodes, not just routers. Documentation for this utility can be read at:

http://wiki.old.lustre.org/manual/LustreManual20_HTML/LNETSelfTest.html

This should get you started.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151117/28d39183/attachment-0001.htm>
