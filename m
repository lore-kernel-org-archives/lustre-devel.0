From: NeilBrown <neilb@suse.com>
Date: Wed, 17 Oct 2018 16:20:51 +1100
Subject: [lustre-devel] [PATCH 00/24] Port Dynamic Discovery to
 drivers/staging
In-Reply-To: <alpine.LFD.2.21.1810150054240.9543@casper.infradead.org>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <alpine.LFD.2.21.1810150054240.9543@casper.infradead.org>
Message-ID: <87lg6xdu8c.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Oct 15 2018, James Simmons wrote:

>> This is a port of the "Dynamic Discovery" series
>> (756abb9cf00b936b3..1c45d9051764e0637ba90b3)
>> to my mainline-linux-with-lustre tree.
>> It is all fairly straight forward, but I don't think I have the
>> hardware to testing properly.  And review never hurts.
>> 
>> This is all in my lustre-testing branch.
>
> Only one patch was incorrect but the verison in lustre-testing is fine.
> Testing has shown no problems.

Excellent - thanks for the review!

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181017/17e36ab4/attachment.sig>
