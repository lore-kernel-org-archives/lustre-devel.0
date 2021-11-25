Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A0E32C433F5
	for <lustre-devel@archiver.kernel.org>; Thu, 25 Nov 2021 10:18:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7942F21FDC3;
	Thu, 25 Nov 2021 02:18:30 -0800 (PST)
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com [52.95.49.90])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E6E9821FDA3
 for <lustre-devel@lists.lustre.org>;
 Thu, 25 Nov 2021 02:18:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.fr; i=@amazon.fr; q=dns/txt; s=amazon201209;
 t=1637835508; x=1669371508;
 h=from:to:subject:date:message-id:content-id:
 content-transfer-encoding:mime-version;
 bh=2O0FPillY1igvD32e4M7A+aDeLL+khdEgqFYnwi7aUQ=;
 b=khE/E6He2wt2AYXX+wgbp3iUBXL6pp4c3V/3uOGlZvWgOjqjpb9UDOhD
 hxYBuEsroV1qRTGkc/McxhlIheR6JfydI/lFHBAZm1eyqffxpS4W6RKuI
 2sTapVPlzIsXPfejrfYF13MZTZAV+XLjHEN4CN3zBu6fkcDgDQlIHdNxq s=;
X-IronPort-AV: E=Sophos;i="5.87,263,1631577600"; d="scan'208";a="157786071"
Received: from iad12-co-svc-p1-lb1-vlan2.amazon.com (HELO
 email-inbound-relay-iad-1a-828bd003.us-east-1.amazon.com) ([10.43.8.2])
 by smtp-border-fw-6002.iad6.amazon.com with ESMTP; 25 Nov 2021 10:18:17 +0000
Received: from EX13D21EUA003.ant.amazon.com
 (iad12-ws-svc-p26-lb9-vlan2.iad.amazon.com [10.40.163.34])
 by email-inbound-relay-iad-1a-828bd003.us-east-1.amazon.com (Postfix) with
 ESMTPS id ECE798145F
 for <lustre-devel@lists.lustre.org>; Thu, 25 Nov 2021 10:18:16 +0000 (UTC)
Received: from EX13D21EUA004.ant.amazon.com (10.43.165.59) by
 EX13D21EUA003.ant.amazon.com (10.43.165.39) with Microsoft SMTP Server (TLS)
 id 15.0.1497.26; Thu, 25 Nov 2021 10:18:15 +0000
Received: from EX13D21EUA004.ant.amazon.com ([10.43.165.59]) by
 EX13D21EUA004.ant.amazon.com ([10.43.165.59]) with mapi id 15.00.1497.026;
 Thu, 25 Nov 2021 10:18:15 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: Recommendation for hsm_restore for directories
Thread-Index: AQHX4eXCVz9L8l9d2EWlS+Oia9v1FA==
Date: Thu, 25 Nov 2021 10:18:15 +0000
Message-ID: <81C95C19-8B9F-47F3-B827-AEA3B9D6E91C@amazon.com>
Accept-Language: fr-FR, en-US
Content-Language: fr-FR
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.43.164.131]
Content-ID: <57CB54FE87B2D344A02D05C461EA7A15@amazon.com>
MIME-Version: 1.0
Subject: [lustre-devel] Recommendation for hsm_restore for directories
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
From: "Degremont, Aurelien via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Degremont, Aurelien" <degremoa@amazon.fr>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SGVsbG8gYWxsDQoNCkknbSBkb2luZyBzb21lIGVhcmx5IHdvcmsgdG93YXJkIGltcGxlbWVudGlu
ZyBhIGRpcmVjdG9yeS9uYW1lc3BhY2Ugc3VwcG9ydCBmb3IgTHVzdHJlL0hTTS4gVGhlIGlkZWEg
d291bGQgYmUgdG8gc3VwcG9ydCBzb21ldGhpbmcgc2ltaWxhciB0byBoc21fcmVzdG9yZS9oc21f
cmVsZWFzZSBidXQgZm9yIGRpcmVjdG9yaWVzLg0KDQpNeSBmaXJzdCB0aG91Z2h0IHdhcyBmb3Ig
dGhlIE1EVCB0byBub3QgZ3JhbnQgTERMTSBsb2NrIGZvciB0aGlzIGRpcmVjdG9yeSBhbmQgaG9s
ZCBpdCwgd2hpbGUgdGhlIGRpcmVjdG9yeSBpcyBnZXR0aW5nIHJlc3RvcmVkIGJ5IGNvcHl0b29s
LCBpbiBhIHNpbWlsYXIgZmFzaGlvbiB0aGFuIHdoYXQgaXMgZG9uZSBmb3IgZmlsZXMuIEJ1dCB0
aGUgaGFyZCBwYXJ0IGhlcmUsIGlzIHRvIGhhdmUgYSB3YXkgZm9yIGNvcHl0b29sIHRvIGFjY2Vz
cyB0aGUgZGlyZWN0b3J5IHdoaWxlIGl0cyBhY2Nlc3MgaXMgYWN0dWFsbHkgcHJldmVudGVkIGJ5
IHRoZSBhYm92ZSBsb2NraW5nLg0KUmVzdG9yaW5nIGEgZmlsZSBpcyB1c2luZyB0aGlzIHNtYXJ0
IHRyaWNrIG9mIHJlc3RvcmluZyBpdCBpbiBhIGRpZmZlcmVudCB0ZW1wb3JhcnkgZmlsZSBhbmQg
dXNpbmcgbGF5b3V0IHN3YXAgYXQgdGhlIGVuZCB0byBtb3ZlIGRhdGEgdG8gdGhlIGFjdHVhbCBy
ZWFsIGZpbGUuIEl0IGxvb2tzIGRpZmZpY3VsdCB0byBkbyB0aGUgc2FtZSB0aGluZyBoZXJlLg0K
DQpEbyB5b3UgaGF2ZSBhbnkgcmVjb21tZW5kYXRpb24gb24gdGhlIHJpZ2h0IHdheSB0byBmcmFt
ZSB0aGlzIGRpcmVjdG9yeSBhY2Nlc3MgZm9yIGNvcHl0b29scz8NCg0KQXVyw6lsaWVuDQoNCg0K
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRl
dmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlz
dHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
