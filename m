From: Eric Barton <eeb@whamcloud.com>
Date: Mon, 13 Sep 2010 14:26:04 +0900
Subject: [Lustre-devel] Lustre community collaboration
In-Reply-To: <EEE116340D7B44499F3DC2765F63852D@BillGWAYLAPTOP>
References: <EEE116340D7B44499F3DC2765F63852D@BillGWAYLAPTOP>
Message-ID: <002d01cb5304$78de72d0$6a9b5870$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter,

I'd like to lend my support to the suggestions you made on community
collaboration that Bill Boas quoted in his last HPCFS email.  It seems
obvious to me that community discussions should take place on a
lustre.org mailing list.  I note you mentioned lustre-discuss (which
I've cc-ed) - but I would have assumed lustre-devel since I think
making coherent sense of development is the single most important
issue for the community.  Actually a new dedicated list, as you
suggest, is better and keeps the existing list clean for technical
issues.

If I had to prioritise community discussion topics, I'd want to put
the contribution process right at the top of the list.  My biggest
concern is keeping the code clean and stable - I think taking care of
that makes everything else 100x easier.

Firstly, I think there should be a requirement for "no surprises" when
it comes to upstream contributions.  All landings have the potential
to destabilize the tree or introduce architectural debt so I don't
think it's reasonable to expect upstream contributions to land at
short notice, whether the rush is by design or by
omission. Contributions should be planned and discussed throughout the
development process to ensure landing proceeds smoothly for both the
upstream gatekeeper and the contributor.  If people wish to benefit
from the presence of a Lustre community, they must accept that
membership also has its duties and responsibilities.

Secondly, I think providing some sort of QA collateral should be
required for upstream contributions.  Code reviews, a test plan and a
test history in standard formats could all relieve the burden on the
upstream gatekeeper.  The 2.0 stabilization effort demonstrated the
value of a test results database for visualizing the progress towards
stability of features in development and directing testing effort on
them. I think we'd all benefit if we could adopt a similar process
across the community.

          Cheers,
                   Eric

Eric Barton
CTO Whamcloud, Inc.
Tel: +44 (117) 330 1575
Mob: +44 (7920) 797 273
