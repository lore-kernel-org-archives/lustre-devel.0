Return-Path: <SRS0=DK0x=IG=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BDC4C433E0
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Mar 2021 14:09:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A8587650F2
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Mar 2021 14:09:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8587650F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4BA1621FE7F;
	Mon,  8 Mar 2021 06:09:38 -0800 (PST)
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com [52.95.49.90])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A9A2A21FD65
 for <lustre-devel@lists.lustre.org>;
 Mon,  8 Mar 2021 06:09:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1615212578; x=1646748578;
 h=from:to:subject:date:message-id:content-id:
 content-transfer-encoding:mime-version;
 bh=+Q2gW4Ucujm4k7e+JIqMhV0Bavnk6oLf90Sc3LwhY20=;
 b=lvxQlGf2Bmc0KqwKh5Iv6r3SCvtlXPXbk/qUH+Yut/Stxw8xIUQnTC0P
 Dnc4pCwl8985afJoPkISusZgBC7JvVN4H0FevPS6vqbyHPuouSbn8eRy8
 zqCglWU51FTj0v1kZ91ktaOlPV0erv9N/0QZTaiP5e+SnF1Qf8BJxWcPy A=;
X-IronPort-AV: E=Sophos;i="5.81,232,1610409600"; d="scan'208";a="95285895"
Received: from iad12-co-svc-p1-lb1-vlan2.amazon.com (HELO
 email-inbound-relay-2a-e7be2041.us-west-2.amazon.com) ([10.43.8.2])
 by smtp-border-fw-out-6002.iad6.amazon.com with ESMTP;
 08 Mar 2021 14:09:29 +0000
Received: from EX13D21EUA001.ant.amazon.com
 (pdx1-ws-svc-p6-lb9-vlan2.pdx.amazon.com [10.236.137.194])
 by email-inbound-relay-2a-e7be2041.us-west-2.amazon.com (Postfix) with ESMTPS
 id 229E8A1D12
 for <lustre-devel@lists.lustre.org>; Mon,  8 Mar 2021 14:09:28 +0000 (UTC)
Received: from EX13D21EUA004.ant.amazon.com (10.43.165.59) by
 EX13D21EUA001.ant.amazon.com (10.43.165.41) with Microsoft SMTP Server (TLS)
 id 15.0.1497.2; Mon, 8 Mar 2021 14:09:26 +0000
Received: from EX13D21EUA004.ant.amazon.com ([10.43.165.59]) by
 EX13D21EUA004.ant.amazon.com ([10.43.165.59]) with mapi id 15.00.1497.012;
 Mon, 8 Mar 2021 14:09:26 +0000
To: Lustre Development List <lustre-devel@lists.lustre.org>
Thread-Topic: LDLM behaviour question
Thread-Index: AQHXFCSm6DtX2f593EWFOGh1ZqlBuQ==
Date: Mon, 8 Mar 2021 14:09:26 +0000
Message-ID: <B489BBDF-36DA-4B79-BCB3-19FBBEEF75E2@amazon.com>
Accept-Language: fr-FR, en-US
Content-Language: fr-FR
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.43.164.179]
Content-ID: <6AC39D8C0315FE4B857AC7A5FBE5DE17@amazon.com>
MIME-Version: 1.0
Subject: [lustre-devel] LDLM behaviour question
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
Reply-To: "Degremont, Aurelien" <degremoa@amazon.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SGkgYWxsLA0KDQpJIHdhcyBub3QgYWJsZSB0byBmaW5kIGEgZG9jdW1lbnQgZ2l2aW5nIHRoaXMg
bGV2ZWwgb2YgZGV0YWlsIG9mIExETE0gYmVoYXZpb3IuDQpJIGhhdmUgYSBiYXNpYyBxdWVzdGlv
biByZWdhcmRpbmcgY29tcGF0aWJpbGl0eSBiZXR3ZWVuIElCSVRTIGxvY2sgZm9yIHRoZSBzYW1l
IGZpZC4NCg0KSXMgaXQgcG9zc2libGUgZm9yIHRoZSBzYW1lIE1EVCB0byBsb2NrIHRoZSBzYW1l
IEZJRCwgd2l0aCAyIElCSVRTIGxvY2ssIHdpdGggZGlmZmVyZW50IGJpdHM/IChpZTogVVBEQVRF
IHZzIExBWU9VVCkNCldoYXQncyB0aGUgYmVoYXZpb3IgaXMgbm90IHdvcmtpbmc/DQoNClNlY29u
ZCBxdWVzdGlvbjogd2hhdCBoYXBwZW4gd2hlbiB5b3UgY2FsbCBtdWx0aXBsZSB0aW1lcyBtZHRf
b2JqZWN0X2xvY2soKSBmb3IgdGhlIHNhbWUgZmlkL3NhbWUgYml0cyBvbiB0aGUgc2FtZSBNRFQ/
DQoNClRoYW5rcw0KDQpBdXLDqWxpZW4gDQoNCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVs
QGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1
c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
