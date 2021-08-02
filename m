Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07B81C432BE
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:17 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ADAD560F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org ADAD560F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 95312352D88;
	Mon,  2 Aug 2021 12:51:11 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1939A35286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:59 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 781041008051;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 75488C2F53; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:36 -0400
Message-Id: <1627933851-7603-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 16/25] lustre: llite: avoid project quota
 overflow
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

RnJvbTogV2FuZyBTaGlsb25nIDx3c2hpbG9uZ0BkZG4uY29tPgoKQ3VycmVudGx5LCBwcm9qZWN0
IElEIGlzIHN0b3JlZCBhcyB1MzIsIG1heCBwb3NzaWJsZQp2YWx1ZSBmb3IgaXQgaXMgNDI5NDk2
NzI5NS4KCkhvd2V2ZXIsIFZGUyByZXNlcnZlIG1heCB2YWx1ZSBmb3Igc3BlY2lhbCB1c2FnZSwg
c2VlCmZvbGxvd2luZyBmdW5jdGlvbjoKCnN0YXRpYyBpbmxpbmUgYm9vbApxaWRfaGFzX21hcHBp
bmcoc3RydWN0IHVzZXJfbmFtZXNwYWNlICpucywgc3RydWN0IGtxaWQgcWlkKQp7CiAgICAgICAg
cmV0dXJuIGZyb21fa3FpZChucywgcWlkKSAhPSAocWlkX3QpIC0xOwp9CgpTbyBxaWRfaGFzX21h
cHBpbmcoKSBjb3VsZCByZXR1cm4gMCBmb3IgaWQgNDI5NDk2NzI5NS4KQSBmdXJ0aGVyIHRyeSBv
biBjaG93biB0ZXN0OgoKJCBjaG93biA0Mjk0OTY3Mjk1OjQyOTQ5NjcyOTUgYy5zaAogIGNob3du
OiBpbnZhbGlkIHVzZXI6IOKAmDQyOTQ5NjcyOTU6NDI5NDk2NzI5NeKAmQokIGNob3duIDQyOTQ5
NjcyOTQ6NDI5NDk2NzI5NCBjLnNoCgpGaXggdG8gY2hlY2sgbWF4IHBvc3NpYmxlIHZhbHVlIGZv
ciBwcm9qZWN0IElEIGluIHRoZQpjbGllbnQga2VybmVsIHNpZGUsIGFuZCBhZGQgYSB0ZXN0IGNh
c2UgZm9yIHRoaXMuCgpXQy1idWctaWQ6IGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dz
ZS9MVS0xNDc0MApMdXN0cmUtY29tbWl0OiAzZmZhNWQ2ODBmMDA5MmFlICgiTFUtMTQ3NDAgbGxp
dGU6IGF2b2lkIHByb2plY3QgcXVvdGEgb3ZlcmZsb3ciKQpTaWduZWQtb2ZmLWJ5OiBXYW5nIFNo
aWxvbmcgPHdzaGlsb25nQGRkbi5jb20+ClJldmlld2VkLW9uOiBodHRwczovL3Jldmlldy53aGFt
Y2xvdWQuY29tLzQzOTM5ClJldmlld2VkLWJ5OiBIb25nY2hhbyBaaGFuZyA8aG9uZ2NoYW9Ad2hh
bWNsb3VkLmNvbT4KUmV2aWV3ZWQtYnk6IEFuZHJlYXMgRGlsZ2VyIDxhZGlsZ2VyQHdoYW1jbG91
ZC5jb20+ClJldmlld2VkLWJ5OiBPbGVnIERyb2tpbiA8Z3JlZW5Ad2hhbWNsb3VkLmNvbT4KU2ln
bmVkLW9mZi1ieTogSmFtZXMgU2ltbW9ucyA8anNpbW1vbnNAaW5mcmFkZWFkLm9yZz4KLS0tCiBm
cy9sdXN0cmUvbGxpdGUvZmlsZS5jIHwgMTEgKysrKysrKysrKy0KIDEgZmlsZSBjaGFuZ2VkLCAx
MCBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvZnMvbHVzdHJlL2xs
aXRlL2ZpbGUuYyBiL2ZzL2x1c3RyZS9sbGl0ZS9maWxlLmMKaW5kZXggMWJmMjM3Yi4uYTRlNDMy
ZSAxMDA2NDQKLS0tIGEvZnMvbHVzdHJlL2xsaXRlL2ZpbGUuYworKysgYi9mcy9sdXN0cmUvbGxp
dGUvZmlsZS5jCkBAIC0zMzIzLDggKzMzMjMsMTcgQEAgaW50IGxsX2lvY3RsX2NoZWNrX3Byb2pl
Y3Qoc3RydWN0IGlub2RlICppbm9kZSwgdTMyIHhmbGFncywKIAkgKiBuYW1lc3BhY2UuIEVuZm9y
Y2UgdGhhdCByZXN0cmljdGlvbiBvbmx5IGlmIHdlIGFyZSB0cnlpbmcgdG8gY2hhbmdlCiAJICog
dGhlIHF1b3RhIElEIHN0YXRlLiBFdmVyeXRoaW5nIGVsc2UgaXMgYWxsb3dlZCBpbiB1c2VyIG5h
bWVzcGFjZXMuCiAJICovCi0JaWYgKGN1cnJlbnRfdXNlcl9ucygpID09ICZpbml0X3VzZXJfbnMp
CisJaWYgKGN1cnJlbnRfdXNlcl9ucygpID09ICZpbml0X3VzZXJfbnMpIHsKKwkJLyoKKwkJICog
Q2FsbGVyIGlzIGFsbG93ZWQgdG8gY2hhbmdlIHRoZSBwcm9qZWN0IElELiBpZiBpdCBpcyBiZWlu
ZworCQkgKiBjaGFuZ2VkLCBtYWtlIHN1cmUgdGhhdCB0aGUgbmV3IHZhbHVlIGlzIHZhbGlkLgor
CQkgKi8KKwkJaWYgKGxsX2kyaW5mbyhpbm9kZSktPmxsaV9wcm9qaWQgIT0gcHJvamlkICYmCisJ
CSAgICAgIXByb2ppZF92YWxpZChtYWtlX2twcm9qaWQoJmluaXRfdXNlcl9ucywgcHJvamlkKSkp
CisJCQlyZXR1cm4gLUVJTlZBTDsKKwogCQlyZXR1cm4gMDsKKwl9CiAKIAlpZiAobGxfaTJpbmZv
KGlub2RlKS0+bGxpX3Byb2ppZCAhPSBwcm9qaWQpCiAJCXJldHVybiAtRUlOVkFMOwotLSAKMS44
LjMuMQoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVz
dHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRw
Oi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
