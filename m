Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2E87C02196
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Feb 2025 17:45:14 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ymv500Hy3z1y52;
	Mon, 03 Feb 2025 09:44:20 -0800 (PST)
Received: from mail-ej1-f42.google.com (mail-ej1-f42.google.com
 [209.85.218.42])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ymv4q1hfYz1x2Q
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 09:44:11 -0800 (PST)
Received: by mail-ej1-f42.google.com with SMTP id
 a640c23a62f3a-aab925654d9so871694966b.2
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 09:44:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1738604644; x=1739209444; darn=lists.lustre.org;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
 :message-id:reply-to;
 bh=WsJHZMmYfcm2oZThLKFFIn7jw2dTqJLE9bbBR3JCrvM=;
 b=J1t+uvSyRuSe9mIXoW8eQ0baZQKWfQueqdbChjUE2Ci5uJxW1pxZ+fb2wexi4g/4kr
 F7y4GsTQcKP7zxJIFDyQrLjl3tU/evWQ/uUJ/6juOT5ESaklOVSz6v3WFr/icyAcxQI/
 uXhVWRAROWU/xoFhIvXGUYBZVrZLtuOZHEI75E+++X+fHWY8anYbPwVJTuXlVQB3/WUZ
 ZDA1v7/vrmzTAKpdnA8vCdG9nF0OwTrrSAn86u8tOPkyFfS0prrEn1VufOwatkXmuxLh
 BtUQh0Q0Jz7KMBhf1PF3fPYYR2qK6Us31CoZMGhBFrJCi0d3NlwxozBS9082BSnjzx5J
 ieRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1738604644; x=1739209444;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:x-gm-message-state:from:to:cc
 :subject:date:message-id:reply-to;
 bh=WsJHZMmYfcm2oZThLKFFIn7jw2dTqJLE9bbBR3JCrvM=;
 b=udWq633wqwQVznP+XMD8aEalB4miCT9vzo8+zL9ja2BLYRuhTfK8/xNviP+UsqnP/k
 LJ1+2W08qyflfM42euQj+TisBO2BqWZGx3rdkqn53LaYyn3/CxAj26tYmTB8j8u5aAxz
 S2/EHyZ0PQ6DwelwUzgXya+9v3B1rlbyytZp9nqWzncC6n6ahCNV2YrFUObbxVctWY8n
 1nXOskksU1i5WQHq62ODdXSBawwwMPf0wqLouat46KvrzEVWPj9CYm9hq5daj9Et4bqE
 DBHsCCaNOpBtYV58Gw6mZWyoHJeTaJPyxINmDSHxEeDMVGg0GO1rXH20bDiVn0TrmBPu
 dwlA==
X-Forwarded-Encrypted: i=1;
 AJvYcCWlmqynPgowDOuqU9bkG7lVZL/5F5CNjCVT65pSuKZoWpo/TzfMkYZ9dwtE1WusGZMRxOaeYZapI18oSQg=@lists.lustre.org
X-Gm-Message-State: AOJu0Yyx2hW9PoN7+jZCtiFNLMQcn0lvB/POm6UWEx93hC1aHvLXKbkV
 d+MCicMnPNJ1UKkwrm2QNryfRyYjBnQUtUUAknfbYEVqhjfEW1fk
X-Gm-Gg: ASbGncsRZCjMMjjh5uEztp2dfkZ2GfaRP1R4ENO+Vvz0GxdGze9R6aYVCv0ke5m17Ln
 uWVchQluTxZGDKSGHS5hBYWOQECFyXSYcv+Fyxuz1Jusj6jdp0yTq1rDYBKw3oCx/NBzBCek156
 yJQOPeP4kMTaDTmV+W/lF+898IRW8ZL5cJZcdwI+mgFElWKPVGX+uNV9UkOBuAuwMNujCsGlufq
 XTugaXLemqLXPajnpidU/9jBXA9aT07XDdXXhLeqJSh2H+4qrj9KIDMtY8KvTqzRwuE6Xoi64jM
 0ak+AFfEt3UBf9lJFnFCMHn+pbjD/RqWHQILNA==
X-Google-Smtp-Source: AGHT+IHFo3gXvDqCiq8TpgVFiT9CBHVkl/lfKNEnjb2TN5S8ZR7Kv5A0Cq5Tf5pFhVE0JqZyb1/tFA==
X-Received: by 2002:a17:907:1c08:b0:ab2:c0b9:68d with SMTP id
 a640c23a62f3a-ab6cfc859b1mr2575730766b.1.1738604644138; 
 Mon, 03 Feb 2025 09:44:04 -0800 (PST)
Received: from smtpclient.apple ([178.19.96.90])
 by smtp.gmail.com with ESMTPSA id
 a640c23a62f3a-ab6e49ffd79sm798204666b.93.2025.02.03.09.44.02
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Mon, 03 Feb 2025 09:44:03 -0800 (PST)
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <587A3C5F-5BA5-48E4-8F36-B368312FD7E6@amazon.com>
Date: Mon, 3 Feb 2025 20:43:51 +0300
Message-Id: <8F103896-AA52-4321-9A57-18A4655F5A55@gmail.com>
References: <660D26F8-92F1-45AD-803A-5AD47988640E@gmail.com>
 <173845071649.22054.5753395310812419468@noble.neil.brown.name>
 <587A3C5F-5BA5-48E4-8F36-B368312FD7E6@amazon.com>
To: "Day, Timothy" <timday@amazon.com>
X-Mailer: Apple Mail (2.3776.700.51.11.1)
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Cgo+IE9uIDMgRmViIDIwMjUsIGF0IDIwOjMzLCBEYXksIFRpbW90aHkgPHRpbWRheUBhbWF6b24u
Y29tPiB3cm90ZToKPiAKPj4gIEV2ZW4gYSBsYXJnZSBjaGFuZ2UgbGlrZSBmb2xpbwo+IGRpZG7i
gJl0IHNlZW0gdG8gaGF2ZSBhIGh1Z2UgaW1wYWN0IG9uIHRoZSBjb2RlLiBKdXN0IGEgbGl0dGxl
IGJpdCBvZgo+ICNpZmRlZidpbmcuCj4gCgpQbGVhc2UgZG9u4oCZdCBmb3JnZXQgLSBORlMgZG9u
4oCZdCBoYXZlIGEgY29oZXJlbmN5IGNvbnRyb2wgZm9yIG5vZGVzLgpCZXR0ZXIgc2F5IC0gY29o
ZXJlbmN5IGNvbnRyb2wgaXMgbGF6eSBhbmQgaGFkIGJhc2VkIG9uIExFQVNFIGxvY2tzLgpBbmQs
IG11Y2ggaGFyZGVyIHBhcnQgLSBORlMgZG9u4oCZdCBoYXZlIGEgbmV0d29yayByYWlkIGZvciBm
aWxlcy4gU28gdGhleSBkb27igJl0IG5lZWRzIHRvIHNwbGl0IGEgbXVsdGkgcGFnZSBmb2xpbyBv
biBsb2NrIGNvbmZsaWN0LgoKQWxleApfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0
cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUt
ZGV2ZWwtbHVzdHJlLm9yZwo=
