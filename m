Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A8708CFD36B
	for <lustre-devel@archiver.kernel.org>; Tue, 25 Nov 2025 00:27:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4dFk5y1yfgz1y1g;
	Mon, 24 Nov 2025 16:27:02 -0800 (PST)
Received: from mail-pl1-f171.google.com (mail-pl1-f171.google.com
 [209.85.214.171])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4dFk5s6wdDz1wL2
 for <lustre-devel@lists.lustre.org>; Mon, 24 Nov 2025 16:26:57 -0800 (PST)
Received: by mail-pl1-f171.google.com with SMTP id
 d9443c01a7336-2984dfae043so44489405ad.0
 for <lustre-devel@lists.lustre.org>; Mon, 24 Nov 2025 16:26:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=dilger-ca.20230601.gappssmtp.com; s=20230601; t=1764030417; x=1764635217;
 darn=lists.lustre.org; 
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
 :message-id:reply-to;
 bh=0O2e6jMniXacHQ/YJKThmvrJBgmemmXTw/N3otC9UbI=;
 b=2ssGEmf6VMkBjtEiQbynuKbRXf7Fsy1zit5Oz9AJgQLNy239hDckVHTap8f/+caM4o
 XJh+KYqwEHpdIJEy5ELnUkutKzLgf231hn4nApzzSLsC53bPEOHrIHEe4fX2YWZyA55s
 YMc2hP5WVMoXYn4HnQ4Z3vFKf4K9AJ/xileNw/67DZH3KaspkawODEMdLn1oXdOmsr9t
 2irCeK+r7V7yl/lqXyaKFKOnHf5w2gtBMaYVWSIdA+ZP+gYB+/EU154XRNtfXgxqpN8E
 MsLEIVHXQGaT0TRDi6v0EEdSIF/YAnfcm8WP44EH3pmqKbml8tbK/7hGiy3u1Mym9oE4
 g6kQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1764030417; x=1764635217;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:x-gm-gg:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=0O2e6jMniXacHQ/YJKThmvrJBgmemmXTw/N3otC9UbI=;
 b=DEaGWgxsXw2IQKny1JW/3LAgbdK6EbmvXAM3SpaF2dYCoHvyUHv+Q1s25GTbD9g/2H
 zsZ4uU3guCpJRigtZHsJGG7O8OuQ1hbqQJRdB5RoG2jy18wo9dojj3V7xVnQhSSdnxNX
 Bv+q/E6EKitkUJX3YHQda8sES17i0NC7q6RS0BdERSYt88blT7sDxJGpgrhSxXkTWQSS
 Nqw/FjB0+3xNdwA7FjPuMD9fK4ir6tlKPcZV5w+iVyRtxTfMUYfGwfLXkt/U66g9nnO9
 U6PZruRUF6711FS17RSczVEfI+3lnENcE0P6AMqq3zrMtLNRzyYHpcYgEhwt1h0rpMTi
 tNHA==
X-Forwarded-Encrypted: i=1;
 AJvYcCXjdT+0GSjsc0RGgSojgYv82cTxN8EEBdWW+xwixkUgDKrrnr3a6n0Ut7HELp5TYwN0OdWrzWq9595NGow=@lists.lustre.org
X-Gm-Message-State: AOJu0YzfmUMtFXLoym0dAUrAzfNph2XpMKkTKBILjv+OqQlFTvOVbZpM
 AV9aSPaa9jlLDIoWfJGxdWO5ecXspyAfUMEmFIzmGDzXzs0L9u/EIoWldT58bQRCLrU=
X-Gm-Gg: ASbGnct4zBNUmfs6qpJIfqPlOf0Z1xhYGv23KI1GNE3jLWiGK+fECbvOmFGAXiWqbFE
 a71eHNR39h5zzhfexXO8E/6EhpX6Me0ElMzd30uDpXFrKcfIWJVf55b5Luc/Jql51F+hS2XNgyW
 /JOlo7FVJhbWgHifcugplz9znWEoWpblQzTIdwyxto9wSKK1Dr1y8TLnvOmqe2hxYljGqUIPA3d
 IHK3K3eLy5Oeh2ain8vOVczkTLdO8XmqRihHRpQL6P5xmwSkNG0ntMEa0xneezK6wavvJ4ZoxAL
 fxmKABBNFdqmPYS5Jv2h38NDiQdl6QSjX8BgUOP3uaw0W+voHbDn1w/jJtuMGByzo3Ka9ZNIgKM
 s2pSHsc04lP2weejlorkLVvAnuCnTMwXhcF3g9M7IM/9ZgIXof+F4kfqzXfTZKiHQBqMITlS7YU
 aU9AU1ZRNdgGiENVYE09trn5hS+zbGtMjuJwtNWRhZmuPBe9Q7yPAzuo0JQqJyUH1Zew==
X-Google-Smtp-Source: AGHT+IHHHe4RuOIYAJE9NR1nLvseUWpQ8eK7SdUpiT7mcdRwfq+7BYBHHYPPwLrGuwSQh0Z+pLK56A==
X-Received: by 2002:a17:903:19e5:b0:290:c0d7:237e with SMTP id
 d9443c01a7336-29b6c68be27mr154238385ad.39.1764030417134; 
 Mon, 24 Nov 2025 16:26:57 -0800 (PST)
Received: from smtpclient.apple (S01068c763f81ca4b.cg.shawcable.net.
 [70.77.200.158]) by smtp.gmail.com with ESMTPSA id
 41be03b00d2f7-bd75e4d3c86sm14943649a12.11.2025.11.24.16.26.56
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Mon, 24 Nov 2025 16:26:56 -0800 (PST)
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.100.1.1.5\))
In-Reply-To: <DM5PR21MB159160C61FB7A113DC551B2EBED0A@DM5PR21MB1591.namprd21.prod.outlook.com>
Date: Mon, 24 Nov 2025 17:26:45 -0700
Cc: =?utf-8?Q?G=C3=B6tz_Waschk?= <goetz.waschk@gmail.com>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Message-Id: <0C993323-B212-44DE-9FC0-B9AD7FB54423@dilger.ca>
References: <CACd6u-qfd=cyJBEmM7TwWM=++AMT8KmVu=97EX24jiukzDPJRA@mail.gmail.com>
 <0BA8A991-6722-4C3D-B98C-5DC2F7365CBC@whamcloud.com>
 <DM5PR21MB159160C61FB7A113DC551B2EBED0A@DM5PR21MB1591.namprd21.prod.outlook.com>
To: Ellis Wilson <elliswilson@microsoft.com>
X-Mailer: Apple Mail (2.3864.100.1.1.5)
Subject: Re: [lustre-devel] Git server down?
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@dilger.ca>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SGkgRWxsaXMsCmluZGVlZCB0aGUgZ2l0LndoYW1jbG91ZC5jb20gPGh0dHA6Ly9naXQud2hhbWNs
b3VkLmNvbS8+IGFkZGVkIGEgc3BhbSBmaWx0ZXIgZHVlIHRvIEFJIEJvdCBzY3JhcGluZwpvdmVy
bG9hZGluZyB0aGUgc2VydmVyLiAgVGhpcyB3YXMgZG9uZSB2aWEgQ2xvdWRmbGFyZSwgYnV0IGl0
IGJsb2NrcwpIVFRQKHMpIGFjY2VzcyBmcm9tIEdpdC4gIFlvdSBjYW4gdXNlIFNTSCB0byBhY2Nl
c3MgaXQgdmlhIHlvdXIgR2Vycml0CmFjY291bnQuICBUaGlzIHdhcyBhbHNvIGltcGFjdGluZyBn
aXQud2hhbWNsb3VkLmNvbS9mcy9sdXN0cmUtcmVsZWFzZSA8aHR0cDovL2dpdC53aGFtY2xvdWQu
Y29tL2ZzL2x1c3RyZS1yZWxlYXNlPgphY2Nlc3MsIGJ1dCB0aGF0IHdhcyAicmVhZC1tb3N0bHki
IGFuZCBhbGwgb2YgdGhlIGRldmVsb3BtZW50IHdhcyBkb25lCnZpYSBHZXJyaXQsIHNvIHRoZSBH
aXRodWIgY2xvbmUgd2FzIHN1ZmZpY2llbnQgZm9yIHJlYWQtb25seSB1c2FnZS4KCgpJJ3ZlIGNs
b25lZCBpdCB0byB0aGUgR2l0aHViIEx1c3RyZSBwcm9qZWN0LCB3aGljaCBpcyBsaWtlbHkgYSBi
ZXR0ZXIKbG9uZy10ZXJtIHJlcG9zaXRvcnkgdG8gdXBkYXRlIGluIGFueSBjYXNlICh0aGVyZSBo
YXNuJ3QgYmVlbiBhbnkgdXBkYXRlcwp0byB0aGUgcHJvdG9jb2wgZG9jdW1lbnQgaW4gMTEgeWVh
cnMuLi4pOgoKaHR0cHM6Ly9naXRodWIuY29tL2x1c3RyZS9sdXN0cmUtcHJvdG9jb2wuZ2l0Cmdp
dEBnaXRodWIuY29tOmx1c3RyZS9sdXN0cmUtcHJvdG9jb2wuZ2l0CgpDaGVlcnMsIEFuZHJlYXMK
Ck9uIE5vdiAyNCwgMjAyNSwgYXQgOToxMuKAr0FNLCBFbGxpcyBXaWxzb24gd3JvdGU6Cj4gCj4g
U29ycnkgZm9yIHJldml2aW5nIGFuIG9sZCB0aHJlYWQsIGJ1dCB0aGlzIGhhcyBwbGFndWVkIG1l
IGZvciBhIHdoaWxlIG5vdy4gIEkndmUgdHJpZWQgZXZlcnl0aGluZyBJIGNhbiB0aGluayBvZiAo
aG90c3BvdHRpbmcgdGhyb3VnaCBteSBwaG9uZSwgcnVubmluZyBubWFwIGFnYWluc3Qgd2hhbWNs
b3VkLCB3aGljaCBkaWRuJ3Qgc2hvdyB0aGUgZ2l0IHNlcnZlciBwb3J0LCB0cnlpbmcgdG8gZG93
bmxvYWQgdmlhIGEgZ2l0IGNsaWVudCBvbiBteSBwaG9uZSwgZXRjKSwgYnV0IG5vdGhpbmcgaXMg
d29ya2luZy4KPiAKPiBXaGVuIEkgdmlzaXQgdGhlIHBhZ2UgdmlhIHRoZSBicm93c2VyIGl0IHdv
cmtzLCBidXQgc2VuZHMgbWUgdGhyb3VnaCBDbG91ZGZsYXJlIGZpcnN0LiAgSSBzdXNwZWN0IHRo
aXMgaXMgd2hlcmUgdGhlIGlzc3VlIGxpZXMg4oCUIENsb3VkZmxhcmUgZG9lc24ndCBwbGF5IHdl
bGwgd2l0aCBzZWxmaG9zdGVkIGdpdCBpbiBtYW55IGNhc2VzLiAgUGl2b3RpbmcgdG8gdGhlIGdp
dGh1YiByZWxlYXNlIG1pcnJvciB3b3JrcyBmaW5lIGZvciBMdXN0cmUgaXRzZWxmLCBidXQgbm9u
LW1pcnJvcmVkIHJlcG9zIG9idmlvdXNseSBkb24ndCAoZS5nLiwgcHJvdG9jb2wuZ2l0LCB3aGlj
aCBJJ3ZlIGJlZW4gd29ya2luZyB0byByZWZhY3RvciBhbmQgbWVyZ2UgaW50byB0aGUgd2lraSku
ICBJIHdhcyBhYmxlIHRvIGdldCB0aGUgZmlsZXMgSSBuZWVkIGJ5IGJyb3dzaW5nIHRoZSB0cmVl
IGFuZCB0aGVuIGNsaWNraW5nIG9uICJzbmFwc2hvdCIsIHdoaWNoIGdpdmVzIG1lIGEgdGFyLmd6
IGZpbGUsIGJ1dCB0aGlzIGlzIGNsdW1zeSBhbmQgSSBoYWQgdG8gaHVudCBmb3IgYSB3aGlsZSB0
byBmaWd1cmUgaXQgb3V0Lgo+IAo+IElmIFBldGVyIG9yIHNvbWVib2R5IGVsc2UgY2FuIHNoZWQg
c29tZSBsaWdodCBvbiB3aGF0IHNlY3VyaXR5IGFjdHVhbGx5IHdhcyBwdXQgaW4gcGxheSBpdCB3
b3VsZCBoZWxwIG1lIHJlYXNvbiBhYm91dCB3aGV0aGVyIHRoaXMgaXMgcmVhbGx5IGp1c3QgbWUs
IG9yIGlmIGxvdHMgb2YgcGVvcGxlIGhhdmUgaGFkIHRvIHBpdm90IHRvIHRoZSBtaXJyb3IgYW5k
IHRoaXMgaXMgYSBtb3JlIGdlbmVyYWxpemFibGUgcHJvYmxlbSBmb3IgdGhlIGdpdC53aGFtY2xv
dWQuY29tIHNpdGUuCj4gCj4gVGhhbmtzIQo+IAo+IGVsbGlzRnJvbTogbHVzdHJlLWRldmVsIDxs
dXN0cmUtZGV2ZWwtYm91bmNlc0BsaXN0cy5sdXN0cmUub3JnPiBvbiBiZWhhbGYgb2YgUGV0ZXIg
Sm9uZXMgdmlhIGx1c3RyZS1kZXZlbCA8bHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmc+Cj4g
U2VudDogTW9uZGF5LCBBdWd1c3QgMjUsIDIwMjUgMTI6NTEgUE0KPiBUbzogR8O2dHogV2FzY2hr
IDxnb2V0ei53YXNjaGtAZ21haWwuY29tPjsgbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcg
PGx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnPgo+IFN1YmplY3Q6IFtFWFRFUk5BTF0gUmU6
IFtsdXN0cmUtZGV2ZWxdIEdpdCBzZXJ2ZXIgZG93bj8KPiAgR8O2dHoKPiAgU29tZSBleHRyYSBz
ZWN1cml0eSB3YXMgcmVjZW50bHkgYWRkZWQgYW5kIGl0IHNlZW1zIHRvIGhhdmUgY2F1c2UgaXNz
dWVzIGZvciBhIGNvdXBsZSBvZiBwZW9wbGUuIE90aGVycyBpbXBhY3RlZCBoYXZlIGZvdW5kIHN3
aXRjaGluZyB0byB1c2UgdGhlIGdpdGh1YiBtaXJyb3IgLWh0dHBzOi8vZ2l0aHViLmNvbS9sdXN0
cmUvbHVzdHJlLXJlbGVhc2UgLSB3YXMgYSBzaW1wbGUgd2F5IHRvIHNpZGVzdGVwIHByb2JsZW1z
Lgo+ICBQZXRlcgo+ICBGcm9tOiBsdXN0cmUtZGV2ZWwgPGx1c3RyZS1kZXZlbC1ib3VuY2VzQGxp
c3RzLmx1c3RyZS5vcmc+IG9uIGJlaGFsZiBvZiBHw7Z0eiBXYXNjaGsgdmlhIGx1c3RyZS1kZXZl
bCA8bHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmc+Cj4gUmVwbHktVG86IEfDtnR6IFdhc2No
ayA8Z29ldHoud2FzY2hrQGdtYWlsLmNvbT4KPiBEYXRlOiBNb25kYXksIEF1Z3VzdCAyNSwgMjAy
NSBhdCA5OjAy4oCvQU0KPiBUbzogImx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnIiA8bHVz
dHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmc+Cj4gU3ViamVjdDogW2x1c3RyZS1kZXZlbF0gR2l0
IHNlcnZlciBkb3duPwo+ICBIaSBldmVyeW9uZSwKPiAgSSBjYW5ub3QgYWNjZXNzIHRoZSBnaXQg
c2VydmVyOgo+ICAjIGdpdCBjbG9uZSAtYiBtYXN0ZXIgZ2l0Oi8vZ2l0LndoYW1jbG91ZC5jb20v
ZnMvbHVzdHJlLXJlbGVhc2UuZ2l0IGx1c3RyZS1tYXN0ZXIKPiBDbG9uaW5nIGludG8gJ2x1c3Ry
ZS1tYXN0ZXInLi4uCj4gZmF0YWw6IHVuYWJsZSB0byBjb25uZWN0IHRvIGdpdC53aGFtY2xvdWQu
Y29tOgo+IGdpdC53aGFtY2xvdWQuY29tWzA6IDI2MDY6NDcwMDozMDMxOjo2ODE1OjMwZjZdOiBl
cnJubz1Db25uZWN0aW9uIHRpbWVkIG91dAo+IGdpdC53aGFtY2xvdWQuY29tWzE6IDI2MDY6NDcw
MDozMDMwOjphYzQzOjhhZjVdOiBlcnJubz1Db25uZWN0aW9uIHRpbWVkIG91dAo+IGdpdC53aGFt
Y2xvdWQuY29tWzI6IDEwNC4yMS40OC4yNDZdOiBlcnJubz1Db25uZWN0aW9uIHRpbWVkIG91dAo+
IGdpdC53aGFtY2xvdWQuY29tWzM6IDE3Mi42Ny4xMzguMjQ1XTogZXJybm89Q29ubmVjdGlvbiB0
aW1lZCBvdXQKPiAgUmVnYXJkcywKPiBHw7Z0eiBXYXNjaGsKPiBfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwo+IGx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QK
PiBsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwo+IGh0dHA6Ly9saXN0cy5sdXN0cmUub3Jn
L2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwoKCgpDaGVlcnMsIEFuZHJlYXMK
CgoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0
cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6
Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
