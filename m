From: NeilBrown <neilb@suse.com>
Date: Thu, 10 Jan 2019 12:46:49 +1100
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
 <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
Message-ID: <87h8ehi8s6.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jan 08 2019, James Simmons wrote:
>
> I have been thinking what would be a better approach since I like to
> approach this problem for the 2.13 time frame. Our admins at my work
> place want to be able to collect application stats without being root.
> So placing stats in debugfs is not an option, which we currently do
> the linux client :-( The stats are not a good fit for sysfs.

How much statistics data are we talking about here?
  /proc/self/mountstats
shows over 2K of stats for NFS filesystems.
Is this in the ball-park or do you need an order-of-magnitude more?

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190110/a990283e/attachment-0001.sig>
