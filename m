From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 20 Aug 2008 13:59:49 -0600
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <op.uf7ac4keatmt0c@goga>
Message-ID: <C4D1D3D5.576E%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ah yes - testing requires the sync and shutdown also.  The former
unfortunately does demand an option, but the justification is now very
clear.

Peter


On 8/20/08 1:42 PM, "Mikhail Pershin" <Mikhail.Pershin@Sun.COM> wrote:

> On Wed, 20 Aug 2008 21:39:13 +0400, Peter Braam <Peter.Braam@sun.com>
> wrote:
> 
>> If I remember correctly the flush is only there to try to reduce
>> rollback.
> 
> Also to be sure that all before barrier is on disk, many test cases about
> recovery rely on the fact that operations before barrier are on disk. This
> is important with HARD failure case especially, without sync before
> barrier the operations before barrier may be lost and affect the tests.
> I agree that syncless variant of barrier is needed but we also need
> barrier with sync depending on test case.
