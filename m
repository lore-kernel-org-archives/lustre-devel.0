From: James Simmons <jsimmons@infradead.org>
Date: Mon, 29 Oct 2018 15:18:14 +0000 (GMT)
Subject: [lustre-devel] Using loff_t or u64 for PFL port
In-Reply-To: <8C539D08-D7F6-4B17-8A8D-01FEFF03BD2E@whamcloud.com>
References: <alpine.LFD.2.21.1810290345010.6811@casper.infradead.org>
 <8C539D08-D7F6-4B17-8A8D-01FEFF03BD2E@whamcloud.com>
Message-ID: <alpine.LFD.2.21.1810291456390.21751@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Oct 28, 2018, at 21:49, James Simmons <jsimmons@infradead.org> wrote:
> > 
> > 
> > While doing the PFL port I noticed a inconsistent use of loff_t and u64.
> > While in Greg's branch several patches landed to make the prototypes
> > match the function with changing any unmatching loff_t/u64 to use u64.
> > I don't know if using u64 solely as the proper solution. What is the
> > proper unit to use?
> 
> James, could you please clarify what part of the code you are referencing?

I see where the divergence happened. The linux client commit 

21aef7d9d6544 (staging/lustre: get rid of obd_* typedefs)

Changed the old obd_off to u64 while in the OpenSFS branch some were
changed to loff_t. A good example is 

int lov_stripe_offset(struct lov_stripe_md *lsm, int index,
		      loff_t lov_off, int stripeno, loff_t *obd_off);

For upstream client its:

int lov_stripe_offset(struct lov_stripe_md *lsm, u64 lov_off,
                      int stripeno, u64 *u64);

The big difference between the two is that loff_t can be a negative
value. I can compile a list of the difference so an audit cna be done.
Then we can go over what should be loff_t and what should be u64.
