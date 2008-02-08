From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Fri, 08 Feb 2008 16:55:33 +0100
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47AB2FA7.10205@Sun.COM>
References: <47AB2FA7.10205@Sun.COM>
Message-ID: <47AC7B75.30603@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

First of all, thanks for your remarks.

Information explained in the architecture documents from the Arch Wiki 
have not been re-explained in the HLD. So some points could be unclear, 
but read or check the arch docs first.
If the HLD must be self sufficent or more details are really needed, let 
me know.
I will clarify some points anyway in the new document version.

Rick Matthews a ?crit :
> Page 10, 4.1, 1) When archived? (probably in Space Manager portion)
>         SAM-QFS archives well ahead of space need.

Concerning the archived copies vunlerability, I'm not sure this is 
Lustre responsability to manage several copies of each of its file 
versions into the HSM...

>         6.1, 100,000 migrations make current migration list operations
>                 problematic (lets say want to move last migration to
>                 be next migration).

You speak about pending migrations ? This is just pointer manipulation. 
I do not see a real problem at this level. This value is only 
algorithmic indications, not about resources (memory, ...)
But we could decrease this value to 10,000.

> Page 13, Lustre object mtime may not be good enough. There are several
>         mechanisms (like touch) to manipulate mtime, which makes it
>         unusable as a last written time.

If fact, this value is only needed for user information, not for Lustre 
internals. Lustre will based is comparison on the FID version.
The mtime field is used for listing the file copies in the HSM, and as 
the lustre fid version is not relevant for the user, will indicates the 
associated file date at this time.

(just a quick example, not the final output)
user$ list_hsm_copies ./foo
Storage    Date         Size         Version
============================================
HSM1       Feb  2  2006 1566162            1
HSM1       Jun 18  2007 1423540            2
HSM1       Jun 18  2007 1900051           54

But the touch could be problematic. Lustre gurus, is there another time 
field we could use instead ? Should we add a 
"last-modification-field-which-ignore-touch" ? Is this really a problem 
is we use display a "touched" time ? In this case, we display what the 
user set on the file, we suppose he did it in purpose.

> Page 15, a variant on 1.5, ask for/return last valid byte offset
>         (perhaps within a range).

Why not... But do you have use cases were the current "Data available" 
feature as explained in 1.5 is not sufficent ?

> Page 28, protection of Lustre extended attributes?

I do not see what you mean.

> Issues:
>         The purge (3.2, Space manager needs to make room) and 4.1
>         "needs to be atomic" is a complex operations. Sequencing is
>         important.

Does "transactionnal" fit ?



I will add a Bugzilla entry and a new updated version the HLD on it, 
next Monday.


Regards,

-- 
Aurelien Degremont
CEA/DAM - DIF/DSSI/SISR
