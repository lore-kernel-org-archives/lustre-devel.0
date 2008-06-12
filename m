From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Thu, 12 Jun 2008 08:39:58 +0400
Subject: [Lustre-devel] COS
In-Reply-To: <op.ucmbvgl8atmt0c@goga>
References: <C475F666.5B11%peter.braam@sun.com> <op.ucmbvgl8atmt0c@goga>
Message-ID: <op.ucmckweratmt0c@goga>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 12 Jun 2008 08:24:42 +0400, Mikhail Pershin  
<Mikhail.Pershin@Sun.COM> wrote:

>
> VBR implementation handle this case, so we didn't forget about this case
> during development. This case wasn't in design and it was found during
> implementation/testing already and solution was discussed with Alex. The
> HLD itself is not yet updated for this case, I am fixing this.
>
>

Sorry, lost details here.
Actually the solution is only preventing assertion on server side and  
return version mismatch if inode can't be reused. Therefore the client  
will not be reintegrated successfully. This is supossed to be fixed fully  
with FIDs so no special workaround was made specially for 1.6

-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
