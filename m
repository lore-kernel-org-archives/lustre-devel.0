Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B942CC433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Oct 2022 07:06:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MgsM66p8pz1wjW;
	Mon,  3 Oct 2022 00:06:26 -0700 (PDT)
Received: from mail.hpc2n.umu.se (molasses.hpc2n.umu.se [130.239.45.242])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MgsM41mYGz1wLh
 for <lustre-devel@lists.lustre.org>; Mon,  3 Oct 2022 00:06:24 -0700 (PDT)
Received: from [IPV6:2001:6b0:e:4a46:571e:6e9:1682:8414] (unknown
 [IPv6:2001:6b0:e:4a46:571e:6e9:1682:8414])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits))
 (No client certificate requested) (Authenticated sender: ake)
 by mail.hpc2n.umu.se (Postfix) with ESMTPSA id 371E611B06
 for <lustre-devel@lists.lustre.org>; Mon,  3 Oct 2022 09:06:21 +0200 (CEST)
Message-ID: <2b52aff5-9bec-1705-f77f-5daa2d8094d8@hpc2n.umu.se>
Date: Mon, 3 Oct 2022 09:06:21 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Content-Language: en-US
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
References: <21061178-bc35-8d8e-e741-ad2046a1b3c2@hpc2n.umu.se>
 <B101335B-23A2-4099-9D00-8832F654DCA4@ddn.com>
From: =?UTF-8?Q?=c3=85ke_Sandgren?= <ake.sandgren@hpc2n.umu.se>
In-Reply-To: <B101335B-23A2-4099-9D00-8832F654DCA4@ddn.com>
Subject: Re: [lustre-devel] review.whamcloud down or me being kicked out?
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SnVzdCBteSBsdWNrIHRoZW4uLi4gOi0pCgpPbiAxMC8zLzIyIDA4OjU2LCBTZWJhc3RpZW4gQnVp
c3NvbiB3cm90ZToKPiBHZXJyaXQgaXMgaW4gbWFpbnRlbmFuY2UgdGhpcyBtb3JuaW5nLCBzaG91
bGQgYmUgYmFjayBsYXRlciB0b2RheS4KPiAKPj4gTGUgMyBvY3QuIDIwMjIgw6AgMDg6NTIsIMOF
a2UgU2FuZGdyZW4gPGFrZS5zYW5kZ3JlbkBocGMybi51bXUuc2U+IGEgw6ljcml0IDoKPj4KPj4g
SGkhCj4+Cj4+IEp1c3QgdHJ5aW5nIHRvIHB1c2ggdG8gcmV2aWV3LCBidXQgZ2V0Cj4+ID09PQo+
PiBzc2g6IGNvbm5lY3QgdG8gaG9zdCByZXZpZXcud2hhbWNsb3VkLmNvbSBwb3J0IDI5NDE4OiBD
b25uZWN0aW9uIHJlZnVzZWQKPj4gZmF0YWw6IENvdWxkIG5vdCByZWFkIGZyb20gcmVtb3RlIHJl
cG9zaXRvcnkuCj4+Cj4+IFBsZWFzZSBtYWtlIHN1cmUgeW91IGhhdmUgdGhlIGNvcnJlY3QgYWNj
ZXNzIHJpZ2h0cwo+PiBhbmQgdGhlIHJlcG9zaXRvcnkgZXhpc3RzLgo+PiA9PT0KPj4KPj4gSXQn
cyBiZWVuIGEgd2hpbGUgc2luY2UgSSBkaWQgdGhpcyB0aGUgbGFzdCB0aW1lIHNvIEkgbWlnaHQg
aGF2ZSBiZWVuIGtpY2tlZCBvdXQuCj4+Cj4+IC0tIAo+PiBBa2UgU2FuZGdyZW4sIEhQQzJOLCBV
bWVhIFVuaXZlcnNpdHksIFMtOTAxODcgVW1lYSwgU3dlZGVuCj4+IEludGVybmV0OiBha2VAaHBj
Mm4udW11LnNlICBNb2JpbGU6ICs0NiA3MCA3NzE2MTM0ICBGYXg6ICs0NiA5MC01ODAgMTQKPj4g
V1dXOiBodHRwOi8vd3d3LmhwYzJuLnVtdS5zZQo+PiBfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwo+PiBsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cj4+IGx1
c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCj4+IGh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xp
c3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo+IAoKLS0gCkFrZSBTYW5kZ3Jlbiwg
SFBDMk4sIFVtZWEgVW5pdmVyc2l0eSwgUy05MDE4NyBVbWVhLCBTd2VkZW4KSW50ZXJuZXQ6IGFr
ZUBocGMybi51bXUuc2UgIE1vYmlsZTogKzQ2IDcwIDc3MTYxMzQgIEZheDogKzQ2IDkwLTU4MCAx
NApXV1c6IGh0dHA6Ly93d3cuaHBjMm4udW11LnNlCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRl
dmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dp
L2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
