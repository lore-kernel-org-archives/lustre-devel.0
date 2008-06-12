From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Thu, 12 Jun 2008 08:24:42 +0400
Subject: [Lustre-devel] COS
In-Reply-To: <C475F666.5B11%peter.braam@sun.com>
References: <C475F666.5B11%peter.braam@sun.com>
Message-ID: <op.ucmbvgl8atmt0c@goga>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 12 Jun 2008 07:38:46 +0400, Peter Braam <Peter.Braam@Sun.COM>  
wrote:

>
> Intuitively (in the absence of a definition) only the server is making
> multiple updates to the directory content and mtime, and these are not
> shared with the clients.  As a result, there are no dependencies for the
> part of the transaction that updates the directory as long as clients do  
> not
> try to gain access with stat or readdir to the new entries in the  
> directory.

Though the only server is doing updates to the directory there are still  
dependencies like create() vs unlink() for the same name. E.g. lost  
create() can cause failed unlink() replay and backwards.

>
> In a good design, issues like this are traceable.  If they are not, we  
> have
> found a defect in the design.  Mike, Zam ? how do busy inodes play into  
> use
> cases and requirements shown in the design document?  To take things one
> step further, please define a busy inode (and I?m having this feeling  
> that
> once you define this, you will immediately add a new requirement to the
> design document).

VBR implementation handle this case, so we didn't forget about this case  
during development. This case wasn't in design and it was found during  
implementation/testing already and solution was discussed with Alex. The  
HLD itself is not yet updated for this case, I am fixing this.


-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
