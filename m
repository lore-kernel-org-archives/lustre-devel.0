From: Nicholas Henke <nic@cray.com>
Date: Thu, 16 Jul 2009 16:27:53 -0500
Subject: [Lustre-devel] Testing LNET
In-Reply-To: <4A5F9999.2040302@cray.com>
References: <9A79889B-CA4B-43E7-9824-79A1F7949AFE@myri.com>
	<4A5F9999.2040302@cray.com>
Message-ID: <4A5F9B59.2080103@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nicholas Henke wrote:
> Scott Atchley wrote:
>>
>
> I've been using LNet SelfTest for my LND development and testing.  It 
> is ok once you get things working - but it is painful to script around 
> and to trace LST errors back to LND transactions.
>
> Nic
>

FWIW: Here are scripts I've been using for LST runs. 'sim_tests.sh' runs 
tests in serial, parallel is...

The 'sim_config' is an easy way to manage different machine configs - 
just set the CONFIG environment variable to the particular file you'd 
like to use.

The cli format is "test size loops" where:
    - test can be 'read' 'write' or 'ping'
    - size is anything <= 1m, i.e; '243k', '2342', '1m'
    - loops is the number to send.

There is a 'NCONN' environment variable that controls the --concurency 
for LST tests, bascially how many RPCs to keep on the wire.

YMMV,
Nic
-------------- next part --------------
A non-text attachment was scrubbed...
Name: sim_tests.sh
Type: application/x-sh
Size: 1143 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090716/133019f2/attachment.sh>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: sim_config
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090716/133019f2/attachment.asc>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: parallel_test.sh
Type: application/x-sh
Size: 1207 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090716/133019f2/attachment-0001.sh>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lnet_selftest_framework.sh
Type: application/x-sh
Size: 6366 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090716/133019f2/attachment-0002.sh>
