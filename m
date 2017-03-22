From: Yan Li <yanli@ascar.io>
Date: Wed, 22 Mar 2017 07:19:51 -0700
Subject: [lustre-devel] [PATCH 1/6] Autoconf option for rate-limiting
 Quality of Service (RLQOS)
In-Reply-To: <D4F6FF83.CB29%jevans@cray.com>
References: <cover.1490122510.git.yanli@ascar.io>
	<99fe8fdaaaa5b6fd36c0782269bc45a580079696.1490122510.git.yanli@ascar.io>
	<D4F6FF83.CB29%jevans@cray.com>
Message-ID: <b2087803-6426-bc07-e349-13a4c7b42d8f@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On 03/21/2017 01:09 PM, Ben Evans wrote:
> I would remove the #ifdef ENABLE_RLQOS blocks, especially in lustre_idl.h
> since you're proposing to add new fields and consume some of the padding
> bits.  It will cause a lot of headache for the next feature that comes
> along and consumes some of those bits.

Yeah, that's a good point. I'll remove it if all are ok with this.

Yan
