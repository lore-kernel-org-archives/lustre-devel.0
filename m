Return-Path: <SRS0=Qh66=G6=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E1ECC433DB
	for <lustre-devel@archiver.kernel.org>; Wed, 27 Jan 2021 12:44:52 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AB7BB207A3
	for <lustre-devel@archiver.kernel.org>; Wed, 27 Jan 2021 12:44:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB7BB207A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cloudlinux.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CA01021F2CC;
	Wed, 27 Jan 2021 04:44:50 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com
 [209.85.167.50])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BC61D21CA85
 for <lustre-devel@lists.lustre.org>; Tue, 26 Jan 2021 23:22:08 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id a12so1277163lfb.1
 for <lustre-devel@lists.lustre.org>; Tue, 26 Jan 2021 23:22:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=cloudlinux.com; s=google;
 h=mime-version:subject:from:in-reply-to:date:cc
 :content-transfer-encoding:message-id:references:to;
 bh=RiB2S5+AhoZPnzmVvbP4nJUdtPAt1sCx3gI2/FA1Kis=;
 b=J6K6utj0RJxFkAzh/Mvkw/BR0SggsR3TD33lDahWLlfIg2oLxZ0DQsRR7YH3pZdrkE
 0ClbYVptBsbZ3ysVXJo37amPnnMfQlt3BAs/TY8GADWu+2fhYroL+5eUXCzTjW9PeR+0
 1xkugDcu8UgxHYjvO7oVGWHvB2zyUlKxKSmEZhDwc5XYOrM+eXL0CNCQmSbsQL26Wpm8
 RkBKjcnZeGd4B18S/ozGIO6Gl/lMkgN7gMOG5MWEglLPafQlvUCwhX2FEZDMWEU4dcs+
 ZZo5EvQdgCDikUndO/QtANWi6ZC61WY8dURtuDOSWNkhsG0wVADURvHBt2cgU7riB/eh
 VfYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
 :content-transfer-encoding:message-id:references:to;
 bh=RiB2S5+AhoZPnzmVvbP4nJUdtPAt1sCx3gI2/FA1Kis=;
 b=Jbq4YrQUKG45dt2EMyFUOjAG1LIFxmrnrM8A4jDYnRnJOm2um3h0RT3ef5S49i6/1Q
 svO0N/weJ+qVSxs/p8Gi7tOEgBDSUG+3N6rZnJfbMT4HeX4XbKEt1WrJ8aNl1eZ2wW5t
 bSWzK9Ig0Q6TGgU11b5fT3gle39W6qoZESa8MWGSenKk+HLuECUScS4F0iSLEeyEjJwg
 sW6tbWbPCezsu8iNmmbIayBHL2EvLmJ0HYybfIzaVy6VfJtx8jGxt5PLCcKOpEpLVYfy
 ehKtlKwWkb1IduPPrgiEszycefb6c9wjrB25dwkGZPqUfv2JC2TdVw1K+FOe8qHU2J5H
 XNmA==
X-Gm-Message-State: AOAM533N8xA66wdq+4sD0tm/Ez8bLOf7IV9zi4L+NjTMnbEnUzRsN4ck
 y0SfozGcPqC7vHSdYVvL63+msQ==
X-Google-Smtp-Source: ABdhPJz+O7w6soWuM27ZuejLIeadkkZXGkmkeqDnkvevztPQ6hbszhJRZJQv7yoMCtnU4WbwFQQa7A==
X-Received: by 2002:ac2:551e:: with SMTP id j30mr4570271lfk.595.1611732127546; 
 Tue, 26 Jan 2021 23:22:07 -0800 (PST)
Received: from [192.168.10.37] ([185.153.133.218])
 by smtp.gmail.com with ESMTPSA id m63sm301481lfa.0.2021.01.26.23.22.06
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Tue, 26 Jan 2021 23:22:06 -0800 (PST)
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.7\))
From: Alexey Lyashkov <umka@cloudlinux.com>
In-Reply-To: <20210121183224.GA4134678@casper.infradead.org>
Date: Wed, 27 Jan 2021 10:21:50 +0300
Message-Id: <90C0C15B-ED78-467A-8629-9B7E9C306F60@cloudlinux.com>
References: <20210121183224.GA4134678@casper.infradead.org>
To: James Simmons <jsimmons@casper.infradead.org>
X-Mailer: Apple Mail (2.3445.9.7)
X-Mailman-Approved-At: Wed, 27 Jan 2021 04:44:48 -0800
Subject: Re: [lustre-devel] Using generic radix trees for large allocations
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
Cc: Lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SmFtZXMsCgp3aGljaCBrZXJuZWwgdmVyc2lvbiB5b3UgdXNlPyBSSEVMIDguMysgb3IgdmFuaWxs
YSBrZXJuZWwgNS4yKyBoYXZlIGEgbG90cyB2bWFsbG9jIHNwZWVkdXAgaW1wcm92ZW1lbnRzLgps
aWtlIHNlcGFyYXRlIHNpbmdsZSBzcGluIGxvY2sgaW50byB0d28gKGFsbG9jICsgZnJlZSkuCgpB
bGV4Cgo+IDIxINGP0L3Qsi4gMjAyMSDQsy4sINCyIDIxOjMyLCBKYW1lcyBTaW1tb25zIDxqc2lt
bW9uc0BjYXNwZXIuaW5mcmFkZWFkLm9yZz4g0L3QsNC/0LjRgdCw0Lso0LApOgo+IAo+ICBPbmUg
b2YgdGhlIGNoYWxsZW5naW5nIGlzc3VlcyBmb3IgdmVyeSBsYXJnZSBzY2FsZSBmaWxlIHN5c3Rl
bXMgaXMgdGhlCj4gcGVyZm9ybWFuY2UgY3Jhc2ggd2hlbiB5b3UgY3Jvc3MgYWJvdXQgNjcwIHN0
cmlwZSBjb3VudC4gVGhpcyBpcyBkdWUgdG8KPiB0aGUgbWVtb3J5IGFsbG9jYXRpb25zIGdvaW5n
IGZyb20ga21hbGxvYyB0byB2bWFsbG9jLiBPbmNlIHlvdSBzdGFydCB0bwo+IHVzZSB2bWFsbG9j
IHRvIGFsbG9jYXRlIHRoZSBwdGxycGMgbWVzc2FnZSBidWZmZXJzIGFsbCB0aGUgYWxsb2NhdGlu
Zwo+IHN0YXJ0IHRvIHNlcmlhbGl6ZSBvbiBhIGdsb2JhbCBzcGlubG9jay4KPiAgTG9va2luZyBm
b3IgYSBzb2x1dGlvbiB0aGUgYmVzdCBvbmUgSSBmb3VuZCBzbyBmYXIgaGF2ZSBiZWVuIHVzaW5n
IHRoZQo+IGdlbmVyaWMgcmFkaXggdHJlZSBBUEkuIFlvdSBoYXZlIHRvIGFsbG9jYXRlIGEgcGFn
ZSB3b3J0aCBvZiBkYXRhIGF0IGEKPiB0aW1lIHNvIGl0cyBjbHVuY2t5IGZvciB1c2UgYnV0IEkg
dGhpbmsgd2UgY291bGQgbWFrZSBpdCB3b3JrLiBXaGF0IGRvCj4geW91IHRoaW5rPwo+IAo+IGh0
dHBzOi8vd3d3Lmtlcm5lbC5vcmcvZG9jL2h0bWwvbGF0ZXN0L2NvcmUtYXBpL2dlbmVyaWMtcmFk
aXgtdHJlZS5odG1sCj4gX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KPiBsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cj4gbHVzdHJlLWRldmVsQGxpc3RzLmx1
c3RyZS5vcmcKPiBodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRl
dmVsLWx1c3RyZS5vcmcKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3Ry
ZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1s
dXN0cmUub3JnCg==
