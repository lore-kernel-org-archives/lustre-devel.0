From: Oleg Drokin <oleg.drokin@intel.com>
Date: Sun, 11 Feb 2018 19:06:30 -0500
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <87eflrrsr7.fsf@notabene.neil.brown.name>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
 <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
 <87o9kylux7.fsf@notabene.neil.brown.name>
 <FC7E817D-BA15-4D0A-9976-F1343F9B022A@intel.com>
 <alpine.LFD.2.21.1802102027560.5700@casper.infradead.org>
 <87eflrrsr7.fsf@notabene.neil.brown.name>
Message-ID: <3E2C6545-B1F2-46AD-8539-A3F65DBE5EF9@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "devel@driverdev.osuosl.org SUBSYSTEM" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Feb 11, 2018, at 6:50 PM, NeilBrown <neilb@suse.com> wrote:
> 
> Maybe - as you suggest in another email - it is due to some
> client/server incompatibility.  I guess it is unavoidable with an fs
> like lustre to have incompatible protocol changes.  Is there any
> mechanism for detecting the version of other peers in the cluster and
> refusing to run if versions are incompatible?

Yes, client and server exchange ?feature bits? at connect time
and only use the subset of features that both can understand.

Bye,
    Oleg
