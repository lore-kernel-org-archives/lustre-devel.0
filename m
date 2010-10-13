From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 13 Oct 2010 02:17:08 -0500
Subject: [Lustre-devel] Query to understand the Lustre request/reply
 message
In-Reply-To: <AANLkTinkgg9tm8c1Zd8O2WPDtEAhkxmut13Wyp6PsTB7@mail.gmail.com>
References: <AANLkTikzzrewMtTrpwkWLCJ3soL+HerfSBU6G3KT6O8j@mail.gmail.com>
	<5A70DB00-9F04-47AF-A31C-01ADA3B87D5E@clusterstor.com>
	<AANLkTinvwRnLHaqv2-tpKpm6R2fBP51OtGR1fQCEa3KP@mail.gmail.com>
	<17D943BA-FF0B-467F-8413-CB8C8184858C@clusterstor.com>
	<AANLkTi==UJQRO+5iBKpUNfFVLWSHz4cumBApbjCz5xBe@mail.gmail.com>
	<72D9946A-6452-4BC3-8C18-D2CA607D82DC@clusterstor.com>
	<AANLkTi=8OuaC20Q5avckBL4LKZ16aYgAJneSq_Wg-sj0@mail.gmail.com>
	<20101013054233.GC1635@oracle.com>
	<AANLkTinkgg9tm8c1Zd8O2WPDtEAhkxmut13Wyp6PsTB7@mail.gmail.com>
Message-ID: <20101013071708.GF1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 13, 2010 at 02:07:06AM -0400, Vilobh Meshram wrote:
> I will try out the new API to create new RPC as per the steps mentioned by
> you for Lustre 2.0 (since I am using 1.8.1.1 right now) .

The new API, incidentally, uses the old API under the hood.  That might
help guide you.  To understand usage patterns for the old API it should
help to look at 2.0 code, particularly layout.c code, then look at
corresponding 1.8 code.

Nico
-- 
