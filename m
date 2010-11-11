From: Eric Barton <eeb@whamcloud.com>
Date: Thu, 11 Nov 2010 12:10:32 -0600
Subject: [Lustre-devel] changelog for whole filesystem?
In-Reply-To: <73AED5C780AE05478241DB067651A92101D11E83@XYUS-EX22.xyus.xyratex.com>
References: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
	<4CC84509.4050609@cea.fr>
	<9759789F-8FD0-464F-9632-E31F0F45287C@oracle.com>
	<4CC97DF7.8040206@cea.fr> <022a01cb7789$55cc7a40$01656ec0$@com>
	<2E7B2EC5-BDCB-41A4-A566-42EC7A72943C@oracle.com>
	<73AED5C780AE05478241DB067651A92101D11E83@XYUS-EX22.xyus.xyratex.com>
Message-ID: <006901cb81cb$bb90e310$32b2a930$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathan wrote...

> This same "initial population of a database from objects" problem
> occurs when trying to replicate a Lustre filesystem using the
> changelog.

That must be a great test case.  If we can reliably reconstruct an
exact replica using a "from empty" changelog, we must have got it
right :)

> The problem is actually more complicated even for a single changelog
> consumer: since iterating through the virtual changelog takes non-0
> time, you're not sure if a virtual record was created before or
> after an actual changelog entry.  E.g. you might try to resolve the
> name of a file for a virtual record either before or after a rename,
> and then later you would see the rename in the changelog, leading to
> an inconsistent view of the namespace.
> 
> If you don't care about having the exact right name, then it's easy
> enough to ignore inapplicable changelog records.

I was trying to hint at the need to filter changes for individual
consumers depending on how far through the initial "from empty"
iteration they are in my original post.  Andreas stated it more
explicitly.  I think you just need to enumerate the cases - e.g. for
rename...

Iterated over yet?               Record
Source Inode   Target Inode      emitted
no             no                none
no             yes               delete target
yes            yes               rename source + delete target
yes            no                rename source

The final case just looks like a rename where the target name didn't
exist already.  In any case, the only real requirement on the stream
of changelog records constructed in the initial iteration is that
consistent filesystem state be reconstructed after the last record
is consumed.

-- 

                Cheers,
                        Eric

Eric Barton
CTO Whamcloud, Inc.
Tel: +44 117 330 1575
Mob: +44 7920 797 273
