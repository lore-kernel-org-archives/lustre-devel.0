From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 8 Jun 2011 23:16:08 -0400
Subject: [Lustre-devel] discontiguous kiov pages
In-Reply-To: <4DEF9E8F.6070202@cray.com>
References: <4DE6F67B.6040207@cray.com> <002c01cc2127$ac5b7da0$051278e0$@com>
	<B91FC92C-00B4-4C0B-A0D1-DA2E6912697D@whamcloud.com>
	<4DEF9E8F.6070202@cray.com>
Message-ID: <58BFE163-3240-4C11-9088-6ABB05EB4646@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jun 8, 2011, at 12:08 PM, Nic Henke wrote:
> Oleg - it isn't clear to me what fix you are suggesting here. Are you 
> saying LNet/LNDs should handle this situation (partial internal page) 
> under the covers by setting up multiple RDMA on their own? This sounds 
> like an LND API change, requiring a fix and validation for every LND. I 
> *think* we might end up violating LNet layering here by having to adjust 
> internal LNet structures from the LND to make sure the 2nd and 
> subsequent RDMA landed at the correct spot in the MD, etc.

What about if we just transfer all such "partial" pages as full pages instead?
Should work for our and your purposes.
For Lustre purposes these two are almost like two different transfers anyway.
In this case we are totally not expecting you to "collapse" the hole.

Hm, I guess this is best handled on the osc level anyway, though. So
perhaps no changes from lnd side then.

Bye,
    Oleg
--
Oleg Drokin
Senior Software Engineer
Whamcloud, Inc.
