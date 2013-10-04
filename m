From: Eremin, Dmitry <dmitry.eremin@intel.com>
Date: Fri, 4 Oct 2013 11:53:15 +0000
Subject: [Lustre-devel] Lustre on Intel Xeon Phi
In-Reply-To: <CABgxfbFoC1bh4zmJmgZJuufN1zViO1e7AogvVMkeOzVRuPw0hw@mail.gmail.com>
References: <CABgxfbFoC1bh4zmJmgZJuufN1zViO1e7AogvVMkeOzVRuPw0hw@mail.gmail.com>
Message-ID: <9FC73D3DBECE0941BD2ED069D268634216EBEEAB@IRSMSX105.ger.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The support of Lustre for Intel Xeon Phi with MPSS 2.1 was introduced in Lustre 2.4. Then the support was extended for MPSS 3.x but in Lustre 2.5 only.

How to compile Lustre with MPSS 2.1

Got to http://software.intel.com/en-us/articles/intel-manycore-platform-software-stack-mpss and download the SOURCE package. Unpack it and find the package-full_src-k1om.tar.bz2 file. Unpack this archive in any location, for example in "/opt/intel/mic/src", then go to this location and execute the following commands:

make defconfig-miclinux
make -C card/kernel ARCH=k1om modules_prepare
 
Now the Intel Xeon Phi kernel is ready for Lustre compilation. Go to location with Lustre sources and execute the following commands:

# NOTE: You should have "intel-mic-gpl-<version>.x86_64" package installed.
export PATH=/usr/linux-k1om-4.7/bin:$PATH 
sh autogen.sh
./configure --with-linux=/opt/intel/mic/src/card/kernel \
--disable-server --disable-tests --disable-doc --without-o2ib \
--host=x86_64-k1om-linux --build=x86_64-pc-linux
make rpms

The following RPMs should be installed on Intel Xeon host with Phi card and Lustre will be deployed to Phi card:

lustre-client-mic-<version>.x86_64.rpm
lustre-client-mic-modules-<version>.x86_64.rpm

After MPSS service restart it's ready to configure and use.

Dmitry.
> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-
> bounces at lists.lustre.org] On Behalf Of Wendy Cheng
> Sent: Tuesday, October 01, 2013 3:18 AM
> To: Lustre-devel at lists.lustre.org
> Subject: [Lustre-devel] Lustre on Intel Xeon Phi
> 
> Do folks have instructions of how to install Lustre client on Intel Xeon Phi ?
> I'm on a relatively old MPSS  (mpss_gold_update_3,
> mic-2.1.6720 linux 2.6.18 kernel). Other cluster nodes run Lustre-1.8.8.
> 
> Thanks, Wendy
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

--------------------------------------------------------------------
Closed Joint Stock Company Intel A/O
Registered legal address: Krylatsky Hills Business Park, 
17 Krylatskaya Str., Bldg 4, Moscow 121614, 
Russian Federation

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
