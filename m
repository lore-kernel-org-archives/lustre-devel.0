From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 4 Mar 2016 11:24:27 -0800
Subject: [lustre-devel] Bug found: Missing lnetctl command on any recent
 daily built package
In-Reply-To: <tencent_4A8CFD8250BEDB3A3649365E@qq.com>
References: <tencent_4A8CFD8250BEDB3A3649365E@qq.com>
Message-ID: <56D9E0EB.1070508@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Please open a bug report for this in the Lustre issue tracker:

  https://jira.hpdd.intel.com/

If you check your configure output you will likely see that it does tell
you that it could not find libyaml.  lnet/autoconf/lustre-lnet.m4
contains the LN_CONFIG_DLC function that should be printing "libyaml not
present".  Granted, it is only a warning, and the consequences of
it being missing are not going to be clear to anyone.

I would not have thought that llmount.sh would require lnetctl.  If it
does, then the LN_CONFIG_DLC function should be throwing an error not a
warning.

And Intel's build farm should definitely be fixed to build lnetctl.
That is worrying if they missed that.

But like I said, open a bug report and we'll get to the bottom of it.

Chris

On 03/04/2016 05:55 AM, 10000 wrote:
> Hi,
>       First I would like to answer the question that llmount.sh cannot successfully run when Install lustre at CentOS 7.2 which I post a month ago, hopefully it would be useful. If you have the same problem, maybe it is due to you have more than one network card on the machine and the ip where hostname sets are not the same as Lustre using, try running "dmesg", and if you find something like "NIDs not found", you can add a conf file in /etc/modprobe.d/ which contains the line "options lnet networks=tcp0(enp0s8)". The word 'tcp0' stands for drivers and the word 'enp0s8' for the network card. You can find more about such configuration at Chapter 15 on the official manual.
> 
>       Now Let's come to the bug (or some reason developers are not specified). It's easy to repeat it at CentOS 7.2, just follow these steps.
>       1. Install all package that it is needed for compiling Lustre but libyaml-devel
>       2. Build the Lustre customerized Linux kernel, my version is 3.10.0-327.el7.x86_64. You can refer the old manual at Chapter 30. Installing a Lustre File System from Source Code although there are some mistakes.
>       3. git clone the newest Lustre-release code from git://git.hpdd.intel.com/fs/lustre-release.git
>       4. Run 'configure' at root folder of lustre-release code with the path of the modified kernel source. It may look like as follow:
>         ./configure --with-linux=/root/rpmbuild/BUILD/kernel-3.10.0_327.el7_lustre.x86_64/ --with-o2ib=no
>       5. run 'make' at root folder of lustre-release code
>       6. Once you finished, just go to the folder lustre-release/lnet/utils and you will see that the lnetctl are not exist while other such as 'lst' is.
>       7. Check the Makefile under that folder, you will find that there comment symbol '#' on line 123:
>             line 121:          sbin_PROGRAMS = routerstat$(EXEEXT) lst$(EXEEXT) \
>             line 122:            $(am__EXEEXT_1) $(am__EXEEXT_2)
>             line 123:          #am__append_1 = lnetctl
>             line 124:          am__append_2 = wirecheck
>             line 125:          subdir = lnet/utils
>           And also at line 176: #am__EXEEXT_1 = lnetctl$(EXEEXT)
>           And also at the folder lustre-release/lnet/utils/lnetconfig there are no 'lnetconfig.la' which should exist because lnetctl need it to compile.
> 
>       It won't help even you run 'configure' and 'make' for more times. And now you install libyaml-devel, you can install it by yum or source. I use yum to install it by simpily running: sudo yum install libyaml-devel.
>       Now you run 'configure' and 'make' again, you will find 'lnetctl' has been successfully compiled and placed at lustre-release/lnet/utils. You can also run './lnetctl' at the folder and find it seems work.
> 
>       Since lnetctl is an important tool to configure LNET, and the total Chapter 9 are tell us how to use it configuring network. I think if it is due to lack of some package, it should have a message to tell us that was lacking a package, however, the 'configure' and 'make' are running successfully without any message but not produce the 'lnetctl'.  That Makefile must be auto-gernerate by running 'configure'. I hope the developers can check this problem, and a bad news is that all recent daily built package at https://build.hpdd.intel.com/job/lustre-master/ , such as '#3330' are not containing 'lnetctl', you can just download, install and check. (Mostly you will get "bash: lnetctl: command not found", I add this to make search engine find this email on purpose which may help others, the Lustre are lacking of documents ^_^)
> 
> Yingdi Guo
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> .
> 
