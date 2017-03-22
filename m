From: Ben Evans <bevans@cray.com>
Date: Wed, 22 Mar 2017 14:27:25 +0000
Subject: [lustre-devel] [PATCH 1/6] Autoconf option for rate-limiting
 Quality of Service (RLQOS)
In-Reply-To: <b2087803-6426-bc07-e349-13a4c7b42d8f@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
	<99fe8fdaaaa5b6fd36c0782269bc45a580079696.1490122510.git.yanli@ascar.io>
	<D4F6FF83.CB29%jevans@cray.com>
	<b2087803-6426-bc07-e349-13a4c7b42d8f@ascar.io>
Message-ID: <D4F801C9.CB40%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'd get rid of all the ENABLE_RLQOS blocks myself, but minimally the
lustre_idl.h ones.

-Ben Evans

On 3/22/17, 10:19 AM, "Yan Li" <yanli@ascar.io> wrote:

>
>On 03/21/2017 01:09 PM, Ben Evans wrote:
>> I would remove the #ifdef ENABLE_RLQOS blocks, especially in
>>lustre_idl.h
>> since you're proposing to add new fields and consume some of the padding
>> bits.  It will cause a lot of headache for the next feature that comes
>> along and consumes some of those bits.
>
>Yeah, that's a good point. I'll remove it if all are ok with this.
>
>Yan
