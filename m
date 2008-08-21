From: Mikhail Pershin <Mikhail.Pershin@Sun.COM>
Date: Thu, 21 Aug 2008 14:03:44 +0400
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <200808211324.09313.alexander.zarochentsev@sun.com>
References: <C4D1B2E1.575A%peter.braam@sun.com> <op.uf7ac4keatmt0c@goga>
	<200808211324.09313.alexander.zarochentsev@sun.com>
Message-ID: <op.uf8d8iklatmt0c@goga>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 21 Aug 2008 13:24:08 +0400, Alexander Zarochentsev  
<Alexander.Zarochentsev@sun.com> wrote:

> On 20 August 2008 23:42:39 Mikhail Pershin wrote:
>> Also to be sure that all before barrier is on disk, many test cases
>> about recovery rely on the fact that operations before barrier are on
>> disk. This is important with HARD failure case especially, without
>> sync before barrier the operations before barrier may be lost and
>> affect the tests. I agree that syncless variant of barrier is needed
>> but we also need barrier with sync depending on test case.
>
> You don't need lctl readonly to do a sync, the replay_barrier function
> from test-framework.sh adds a sync explicitly

You are right, it is safe in that case.


-- 
Mikhail Pershin
Staff Engineer
Lustre Group
Sun Microsystems, Inc.
