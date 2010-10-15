From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Fri, 15 Oct 2010 20:22:01 +0300
Subject: [Lustre-devel] Query to understand the Lustre request/reply
	message
In-Reply-To: <AANLkTi=f1v-09+Uo+mtNknQk+pJt71n=kpHnR1i35fxG@mail.gmail.com>
References: <AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<B315579D-2A4F-482F-B02E-679441D4CA66@clusterstor.com>
	<20101013071201.GD1635@oracle.com>
	<49BEA69F-6931-473E-AA86-4A676A71607A@clusterstor.com>
	<20101013074345.GH1635@oracle.com>
	<023F45A1-E881-4FD2-AF75-93324876C909@clusterstor.com>
	<AANLkTinJOer5Uid0X3pG3nK_RYkxzsoYsmtLPA20Lsj4@mail.gmail.com>
	<20101014002844.GY1635@oracle.com>
	<FC5171E3-DC54-4FC2-B723-7787BE41BD80@clusterstor.com>
	<20101014051852.GZ1635@oracle.com>
	<E95A1DEA-5447-4B6D-95B7-0BB8D96BDDDE@oracle.com>
	<401C408D-C677-48EC-93FE-03333CCD9478@clusterstor.com>
	<AANLkTi=iXhG1rZ=Q+1Gv4abWvLFO6CS=ZLV26KEKWPwy@mail.gmail.com>
	<419E085D-61B9-4434-A172-1A1DAC99B070@clusterstor.com>
	<AANLkTikHD_16NN_Ld6rXwmTERMPxfrbqYLWqwu_QwP1E@mail.gmail.com>
	<7E0BFE49-914F-44AC-9534-D0544F83878D@clusterstor.com>
	<AANLkTikyGYF=atFyZXr99RdJ5JMc6ef4wgXXWA7pEzmV@mail.gmail.com>
	<AANLkTik8gqaqEadz2w-0ZW4EvjE98SoZ8mYBqNF9on7d@mail.gmail.com>
	<F6E7C0A5-B1E7-4792-A0C3-4A367DF8DEDF@clusterstor.com>
	<AANLkTi=f1v-09+Uo+mtNknQk+pJt71n=kpHnR1i35fxG@mail.gmail.com>
Message-ID: <1D568B58-37C5-4B8A-81EC-8451D8B5EB7D@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

first comment. please use diff -p to see what function has changed.
second, please use CDEBUG() if need :) you can set debug level via sysctl -w lnet.debug=-1, sysctl -w lnet.debug_subsystem=-1 
after it you can get very detail log via lctl dk (dump_kernel) > $log-file.
other comments i say tomorrow.


On Oct 15, 2010, at 19:25, Vilobh Meshram wrote:

> Hi Alexey,
> 
> I have attached the diff file .Please have a look at it and please let me know your comments /suggestions.
> 
> Thanks again.
> 
> Thanks,
> Vilobh
> Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio
> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101015/c7a2c826/attachment.htm>
