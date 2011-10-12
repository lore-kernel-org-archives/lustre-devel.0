From: Isaac Huang <isaac_huang@xyratex.com>
Date: Wed, 12 Oct 2011 00:18:36 -0600
Subject: [Lustre-devel] IPv6 NIDs
In-Reply-To: <06e901cc8818$95acbc60$c1063520$@com>
References: <06e901cc8818$95acbc60$c1063520$@com>
Message-ID: <20111012061836.GA4154@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Oct 11, 2011 at 02:20:44PM +0100, Eric Barton wrote:
> ......
> IPv6 compatible NID:
> 
> 1. Minimum: 128 bit address-within-LNET + 32 bit LNET number.
>    160 bits / 20 bytes total.

(1) might cause alignment problem somewhere. I remember that the
PTLLND is picky on alignments, and there might be more such places.

> 2. Hedge a little by reserving an additional (say) 32 bits for
>    something we've not thought of yet and keeping the total a
>    multiple of 64 bits to simplify alignment.
>    192 bits / 24 bytes total.
> 
> 3. Hedge a lot with a nice round number.
>    256 bits / 32 bytes total.
> 
> (2) gets my vote currently...

I'd feel happy to pay the extra 8 bytes for the peace of mind that I
wouldn't have to handle this again.

- Isaac
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
