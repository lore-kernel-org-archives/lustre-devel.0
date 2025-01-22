Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0261CC02182
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Jan 2025 11:13:34 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YdLzH3YlJz1xPW;
	Wed, 22 Jan 2025 03:13:15 -0800 (PST)
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com
 [209.85.221.46])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YdLzB57sJz1x6w
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 03:13:05 -0800 (PST)
Received: by mail-wr1-f46.google.com with SMTP id
 ffacd0b85a97d-3862b40a6e0so4369096f8f.0
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 03:13:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1737544384; x=1738149184; darn=lists.lustre.org;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
 :message-id:reply-to;
 bh=1PbEcJpdLkQSSdJly5huIhYFN8Dp+FXq9Z8+ETuxbg0=;
 b=bndgV27t8//wjZHU+o1NJqr9lQijsyl/lr6+Zww0DpewKHL5vwbQiE8I7ITqmkrNFf
 AGnxbS26jhEG/73kI53yk2u+6S6RcFF1ZAae/0pPS5F2RYwkEE7EA5CMO+f1LWhB0Wlw
 DzNRHuDkx9iXHMvGGqATC3b3e8V3vfaeRJ/+Vr3wumW6OIsGghs/vxfMkbd6uk+cVxXS
 A/+wApleptJrwdKJk1xYrvBTaAeVZuor9GWUHW4xIOHBy7DnyciIJDClBRFXM/dDkolv
 kO2jlZAdoIInhybSApJd2V0fnGqLbcq3SSPEc6qfq6aScruX8e3St67n+lNHL/AnnbnG
 7DYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1737544384; x=1738149184;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:x-gm-message-state:from:to:cc
 :subject:date:message-id:reply-to;
 bh=1PbEcJpdLkQSSdJly5huIhYFN8Dp+FXq9Z8+ETuxbg0=;
 b=KMx/hd6bJqlROxvTIvQoaPcWimKko0BUXVsNqDyRewh9acfvHE7UgpTFKBowQ94acC
 xAHPqsj4xQnbmLWIbEISpyPPpa5GTzqJAIRjj+1WCXzqGKhWWu0Umw2/Z3gXulAG8SPL
 NjVlry8WDEA79NTSOkAnqM98XauMlEVaTaue4qSM9rt9rvef6SVxPhP54B6wONIDh8Mm
 XnJ7ZHnEZzYAe2rpWTfRDrxhKisv/m5lL5dERAuAgEOrAAFG4fzPTUbboqtnOr6SZ03E
 puAE3iOXElPvNzkntqwfXfprreFHmni+fq3gUlWVhOhimQZevXW3J5gkd0XyfUCvoguI
 r6ug==
X-Gm-Message-State: AOJu0YwYNN13yyTfXitAMcmdOirFRRBaNdCzqO6b70Le1+43cFrM5vOp
 wI2Jid/cz9F6Ltrq12wtvaS7K3D0iDg/2N5gvAECegfnqlk5Xlpx
X-Gm-Gg: ASbGncs1+TGFRBC3PN30j/bw9CwLNuE+UTS5r2+27+W9EmxyC4O1w7hPckObF0kdUaC
 eD+Xi7LmCUZgzFM3jBN699jOMiJImb2lGEniRijpqtNoQQAy9QztOSDX+lhNMYrA3WtcKHhOVpE
 PQZ67IC1UE6en8FrvOU0dlJDh1bW8HEdNj18qBH+uCzi1DDbpag8RN00pIOPqwGTLPCjH+WewI2
 H+XHmGtj9ErfigEXn+HLTepj4b9D3o0431uryoT/1bRLxLVUBfDo12GbAJxc84EABcWk97QMs55
 oC7iTx2j7mN7CyfnuYJLCkpmCo5SXUqFbPJywiqM
X-Google-Smtp-Source: AGHT+IGZbGip5SCqhepep/uzk5lLm7vxvw4oc6/Lf1lAZZXjjo1NNHNrFWyKPCxou5sDFcuOGgJeAA==
X-Received: by 2002:adf:ef4f:0:b0:38a:418e:bee with SMTP id
 ffacd0b85a97d-38bf57a2843mr13145481f8f.42.1737544383466; 
 Wed, 22 Jan 2025 03:13:03 -0800 (PST)
Received: from smtpclient.apple (vps-b708d385.vps.ovh.net. [57.129.16.80])
 by smtp.gmail.com with ESMTPSA id
 ffacd0b85a97d-38bf327decbsm16249084f8f.90.2025.01.22.03.13.02
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Wed, 22 Jan 2025 03:13:03 -0800 (PST)
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <3E182046-BEC0-4C44-953A-E0C7024D30B8@amazon.com>
Date: Wed, 22 Jan 2025 14:12:50 +0300
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Message-Id: <3685F420-52D1-46C8-9A04-666B7FFF45F4@gmail.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <3E182046-BEC0-4C44-953A-E0C7024D30B8@amazon.com>
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

VGltb3RoeSwKCgo+IDIyINGP0L3Qsi4gMjAyNeKAr9CzLiwg0LIgMDk6MzUsIERheSwgVGltb3Ro
eSA8dGltZGF5QGFtYXpvbi5jb20+INC90LDQv9C40YHQsNC7KNCwKToKPiAKPiBJJ3ZlIGNyZWF0
ZWQgYSBzZWNvbmQgZHJhZnQgb2YgdGhlIHRvcGljIGZvciBMU0YvTU0uIEkgdHJpZWQKPiB0byBp
bmNsdWRlIGV2ZXJ5b25lJ3MgZmVlZGJhY2suIEl0J3MgYXQgdGhlIGVuZCBvZiB0aGUgZW1haWwu
Cj4gCj4gQmVmb3JlIHRoYXQsIEkgd2FudGVkIHRvIGVsYWJvcmF0ZSBvbiBOZWlsJ3MgaWRlYSBh
Ym91dCB1cGRhdGluZwo+IG91ciBkZXZlbG9wbWVudCBtb2RlbCB0byBhbiB1cHN0cmVhbS1mb2N1
c2VkIG1vZGVsLiBGb3IgdXBzdHJlYW1pbmcKPiB0byB3b3JrLCB0aGUgbm9ybWFsIGRldmVsb3Bt
ZW50IGZsb3cgaGFzIHRvIGdlbmVyYXRlIHBhdGNoZXMgdG8gbWFpbmxpbmUKPiBMaW51eCAtIHdo
aWxlIHN0aWxsIHN1cHBvcnRpbmcgdGhlIGRpc3RybyBrZXJuZWxzIHRoYXQgbW9zdCBwZW9wbGUg
dXNlCj4gdG8gcnVuIEx1c3RyZS4gSSB0aGluayB3ZSBjYW4gZ2V0IHRoaXMgcG9pbnQgaW4gc3Rh
Z2VzLiBJJ3ZlIHByb3ZpZGVkCj4gYSBoaWdoLWxldmVsIG92ZXJ2aWV3IGluIHRoZSBuZXh0IHNl
Y3Rpb24uIFRoaXMgd29uJ3QgYmUgd2l0aG91dAo+IGNoYWxsZW5nZXMgLSBidXQgdGhlIG1ham9y
aXR5IG9mIHRoZSB0cmFuc2l0aW9uIGNvdWxkIGhhcHBlbiB3aXRob3V0Cj4gaW50ZXJydXB0aW5n
IGZlYXR1cmUgd29yayBvciBub3JtYWwgZGV2ZWxvcG1lbnQuCgpDYW4geW91IGV4cGxhaW4gaG93
IEx1c3RyZSBwbGF0Zm9ybSBmcmFnbWVudGF0aW9uIHdpbGwgYXZvaWQgPwoKSSBwb3N0ZWQgZXhh
bXBsZSBlYXJseSwKRGlzdHJvIGhhdmUgbG9ja2VkIGEgTHVzdHJlIHZlcnNpb24gaW4gcmVsZWFz
ZSB0aW1lLiBCdXQgTHVzdHJlIHNlcnZlciBoYXZlIGEgbGltaXRlZCBjb21wYXRpYmlsaXR5IC0g
aW4gbW9zdCBjYXNlcyArLy0gMeKApjIgcmVsZWFzZXMgZ3VhcmF0ZWUgdG8gYmUgY29ubmVjdGVk
LiBTbyBzdGFsZSBhbmQgYWdlZCBjbGllbnQgd2lsbCBsaXZlIGluIHRoZSBkaXN0cmlidXRpb24g
a2VybmVsLiBBbmQgaXQgd2lsbCBkb27igJl0IHdvcmsgZm9yIG1vZGVybiBzZXJ2ZXJzLgppdOKA
mXMgdmVyeSBlYXN5ICBPbmNlIGRpc3RyaWJ1dGlvbiBsaXZlIHRpbWUgfjh5LiBTbyBjbGllbnRz
IHdpbGwgYmUgbmVlZHMgdG8gZHJvcCBpbiBrZXJuZWwgbHVzdHJlIGNsaWVudCBzdXBwb3J0IGFu
ZCBpbnN0YWxsIGEgbHVzdHJlIGNsaWVudCBmcm9tIGFuIGV4dGVybmFsIHNvdXJjZXMuIFdoaWNo
IGhhdmUgbm8gZGlmZmVyZW5jZXMgd2l0aCBjdXJyZW50IHN0YXRlLiAKTmV4dCBzdGVwIGlzIHNv
cnQgb2YgZGlzdHJpYnV0aW9ucyB3aGljaCBoYXZlIGEgZGlmZmVyZW50IGx1c3RyZSB2ZXJzaW9u
cyB3aGljaCBub3QgY29tcGF0aWJsZSBlYWNoIHRvIG90aGVyLgpCb3RoIHRoZXNlIGluY3JlYXNl
IGEgc3VwcG9ydCBjb3N0IC0gb25jZSBsYXJnZSBudW1iZXIgdmVyc2lvbnMgbmVlZHMgc3VwcG9y
dGVkLCBzbyBkZXZlbG9wbWVudCB3aWxsIGRyb3BzIGFuZCBhbGwgdGltZSB3aWxsIHNwZW50IHRv
IHN1cHBvcnQuCgpJdCB0aGlzIGlzIG5vdCBlbm91Z2ggLSBsZXRzIG9uZSBtb3JlLiBLZXJuZWwg
QVBJIGlzbuKAmXQgc3RhYmxlIGVub3VnaCAtIHNvIGxhcmdlIG51bWJlciByZXNvdXJjZXMgd2ls
bCBiZSBuZWVkcyBzcGVudCB0byBzb2x2ZSBlYWNoIGtlcm5lbCBjaGFuZ2UgaW4gbHVzdHJlLiBD
dXJyZW50bHksIGl04oCZcyBpbiB0aGUgYmFja2dyb3VuZCBhbmQgZG9u4oCZdCBpbnRlcnJ1cHQg
cHJpbWFyeSB3b3JrIGZvciBzdXBwb3J0aW5nIGFuZCBkZXZlbG9wbWVudCBhIG5ldyBMdXN0cmUg
ZmVhdHVyZXMuCgpTbyB0aGF0IGlzIHByb2JsZW1zIGZvciBMdXN0cmUgd29ybGQgLSB3aGF0IGlz
IGJlbmVmaXRzPwoKCkFsZXgKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KbHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVz
dHJlLm9yZwpodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVs
LWx1c3RyZS5vcmcK
