From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Wed, 20 Aug 2008 23:42:39 +0400
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <C4D1B2E1.575A%peter.braam@sun.com>
References: <C4D1B2E1.575A%peter.braam@sun.com>
Message-ID: <op.uf7ac4keatmt0c@goga>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 20 Aug 2008 21:39:13 +0400, Peter Braam <Peter.Braam@sun.com>  
wrote:

> If I remember correctly the flush is only there to try to reduce  
> rollback.

Also to be sure that all before barrier is on disk, many test cases about  
recovery rely on the fact that operations before barrier are on disk. This  
is important with HARD failure case especially, without sync before  
barrier the operations before barrier may be lost and affect the tests.
I agree that syncless variant of barrier is needed but we also need  
barrier with sync depending on test case.

-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
