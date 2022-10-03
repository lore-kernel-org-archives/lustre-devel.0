Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BCD89C433FE
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Oct 2022 06:56:18 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mgs7Q2nxTz1wbx;
	Sun,  2 Oct 2022 23:56:18 -0700 (PDT)
Received: from NAM04-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam04on2085.outbound.protection.outlook.com [40.107.102.85])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mgs7N54VPz1wLh
 for <lustre-devel@lists.lustre.org>; Sun,  2 Oct 2022 23:56:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=lYhKdu456zlpfM0T15YqBhyZPIZY2MwPLdWJRP/znCkrdzJ+HybJRLc6whigHKST9E3boPUfln1cW5t6WSV4P1JRJl1s+WsgzrTHKVu6RiN1/61YhgQSfRYq+Xpbxtopf97r0TXVNGjbw8abaUX8o6JiqUgaNV7eUpbIuJWHp7mtwBpqCcJ1d6AT6+fHipQl5lON4ek29wCrmCH8eZnFhuhoMgj+LO6uqqRV/Bzq8rfm5n1mJbFp0uvaI0Piw2QDhf3lLW7FoY0zdTRB/Uvk3cOL86MdyhIs/fwwvHfBQ+u1GftLylUv6iJoJz41Z2ug2dzpbJHrFv0Eb4+AWFxblA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=QU0Tp/DVeX/d74nXFP9BK9jNP9dH+B0F9YMeBScap04=;
 b=bO0P7oUCMnOMDyFT4cLKy+okpCjFiurriQKzkoqOBdyr/5Gohzw9sRN19x3m/6jgPQJVrKnbwbvMNjDP+2OYMvQpLSDoWNjPrsiELY5q3WMldyvrQYEM157RM3+NKim85GRNULQo8nTvo67NtO30/1R5rlhMewlVBuTZLurykyvBCOmFMoZbpc2BpPdBlVZDe9KTA3TiY97xl1OvCp5VWm8zV6YDzsIryvJBObdI/hbcyFwPOLRcXgK7ex36jdfneJxoUTyRuPA47l3SVtv9QNaiQ2oL1V82nJ2V1UbsJT93BNTyXArhestUOhU3S86Ng12b1BbjZWOU0wOFJyiJ+g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QU0Tp/DVeX/d74nXFP9BK9jNP9dH+B0F9YMeBScap04=;
 b=cj1f6miGwPeZg1ynXQv9VWC6adXRpMY6/yyTKEQxFURLRMEN3BMn2KOVyy44/MiL9Mgq+8xQ31A9ZFeixoi9v7lc4RhVSRRsdQAm9pxGe1q0vf0sUSj5jvAvmAEdAtP8mjI5iFlyQPEG6mv0P0DWhx1Nl127sjwmM9pXr2j5C1Y=
Received: from DM6PR19MB3769.namprd19.prod.outlook.com (2603:10b6:5:229::19)
 by SA0PR19MB4443.namprd19.prod.outlook.com (2603:10b6:806:c3::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5676.28; Mon, 3 Oct
 2022 06:56:12 +0000
Received: from DM6PR19MB3769.namprd19.prod.outlook.com
 ([fe80::fd95:936b:16b7:2535]) by DM6PR19MB3769.namprd19.prod.outlook.com
 ([fe80::fd95:936b:16b7:2535%3]) with mapi id 15.20.5676.028; Mon, 3 Oct 2022
 06:56:12 +0000
To: =?utf-8?B?w4VrZSBTYW5kZ3Jlbg==?= <ake.sandgren@hpc2n.umu.se>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] review.whamcloud down or me being kicked out?
Thread-Index: AQHY1vS+nNGAMGOQLEmr9o4fpRPTDK38PIYA
Date: Mon, 3 Oct 2022 06:56:12 +0000
Message-ID: <B101335B-23A2-4099-9D00-8832F654DCA4@ddn.com>
References: <21061178-bc35-8d8e-e741-ad2046a1b3c2@hpc2n.umu.se>
In-Reply-To: <21061178-bc35-8d8e-e741-ad2046a1b3c2@hpc2n.umu.se>
Accept-Language: fr-FR, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR19MB3769:EE_|SA0PR19MB4443:EE_
x-ms-office365-filtering-correlation-id: b2b5e5e3-72ac-4105-fea6-08daa50c5bbe
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: yr8LLwpV5HOi0oozokLP+bBunl0Ji+7LaZ9JT+UkF8JJRvl2FlbW6r0fzgyZn3a1x2JuMkkCjSzW+Hc0MglzhI0bgIx1B7DIP1jV/vYUF8kz6c6aIinGxelP10EFzyTk4q6TckHzo1tNtjb0IS8vAc9npeHCE9CLQCdqTu/1vsK+vVPK9ze4NQnWMlSbI8KAHi0Bf5rpVof5f2S1+IOhqtS8GfqDLfq1P4v4U3+3z8xCKGL1kqFYN03Ed5xeEriZuOdi2i0yod5Yc2HeGNdaYbHKrByJQDsF0I4NwLc1LwpnRQBuEURCgS8YxWhxG+pIxcJmrajV1LbJhO8aPZ4nDcE7GCAPcT8hFyBym+z56QxwSWmEhdD+WJq8IGkcMhMx/X0boQKK7H0Aoa32fuknoaTLw134deZEcJ4U9jc9gEx99xLtYffEJcCYUt1NR4XhsEBebtF+SWNsXQH7uMo8EjFroW9iZ6wvqzHLhHOa6K1CaIloZ+pntN74iCgwwT7gS9CgQ7uc6hNk40ykoRImYxROagN6bxhRvesGRsr5NK5DGgBSPk2ABFz4lQOv7H+AU4qF6UgA35i/o2PoRxhwKacQuRcMHwVOpcOlcP+EDggJdZN+GYCxe0YtwSW4Nv9ZFipd4tAbPrRjW2EDJo2/KzbOAo84dnMU/p6eekXcrF2DmoihhnMfC77bfchgTeIfO4eJofKmGtdo3ipwau4J4RJqXvFrYUKE3Ldv0cbLDFomAV0mCB6anZaKFswkK0FT3f7Udq+nYbYTmjQN5jL4upmgx/B2DFakIts7WtJYV19K4Yw8q+t8fN2S4ezNJmj1dtEmFJixVfKtpoO+ITiWMw==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR19MB3769.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230022)(4636009)(396003)(346002)(376002)(136003)(366004)(39850400004)(451199015)(36756003)(33656002)(6916009)(6512007)(26005)(86362001)(2616005)(6506007)(71200400001)(478600001)(186003)(6486002)(966005)(66574015)(2906002)(83380400001)(38070700005)(316002)(8936002)(41300700001)(91956017)(5660300002)(38100700002)(66946007)(64756008)(76116006)(4744005)(4326008)(66556008)(8676002)(66476007)(66446008)(122000001)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?KzNZUmovd0FITFJOc2w5dVFYWEtvRmcrZjEyNFdML2ZoU3Y5YXhBMThBY2ZH?=
 =?utf-8?B?UzUvYy9NSU5WL0xtdmJEeE1BUTdMOHl2U1BLdzNJWEpNUW9xekgwUndMVDlm?=
 =?utf-8?B?OFV1UGpHcEd0N0x4VlQ0aDdFUmMxTEtzKzdSdnFCMWpOZEh2U0JrWHNsTy90?=
 =?utf-8?B?R1RGVldYK3R1TkFzdXlaMi9zU3VVOTBGenRwb21kUjR3WXBPWDMvZUN3TkRo?=
 =?utf-8?B?UkU0NSt0SWw5YzRXeGtUdGZLSWIrWDR2Wm5SS3I5OFFFb2JqUUxDZXdsajFU?=
 =?utf-8?B?REpXQWplQ0JzMHNWbmZuakdCamhHR1Bqb1Fad3dUT0s0OFBsM1RqS0tEUWVx?=
 =?utf-8?B?U0pKUnlQdnVlYW43eXJvVEdiTlBxamNGL3ZDbWErMXhLelRrN3NBbGdGNUlU?=
 =?utf-8?B?T2drN3pmQVU2N01SZmhIaTU2M3VnYzA4YWd4NkJPN2FFVXhuaWM0L1lxanlE?=
 =?utf-8?B?L1V6cGxqeEFLdHViY2l3bC9VYWhEd2tpMzAzZzhDdlBNTUs5bXdJQThrVjRp?=
 =?utf-8?B?WVYyaGJ5VGJ4Z0lReXVLY0JOek9KeDRJSUNab0xJZkNCVksxVVYyZUdnU0x3?=
 =?utf-8?B?dG4xNCtSNWc5dk0yWlprYUlzNFQvaEdlOUdSUXJsK2wweXdHVXViNTM5SEwy?=
 =?utf-8?B?NmY4WHFLTFYwRFo4Q1dsOEN6OElXY1pmUGl4akphc0kwSHpKVFVnbGlGSEZi?=
 =?utf-8?B?S0gvbEoyT1FNcUlNeU5GT21xSDRKZk9tV2VHZTlyTk1icnlnd3ZnZklJUFlv?=
 =?utf-8?B?bHcrUXFrczRJRUJIUEpaMzZzZ1hZQ2Rmd1czanB1TVFGL3pvYk1MSmNRL1Rv?=
 =?utf-8?B?OUd4dFNaMjRWOHR2RExDOURuRTVGLzQ4SlNPZ0dtK3pESDVzbFFEMXdrZWM2?=
 =?utf-8?B?ZU9lcys1ZFhOT0s0YjlLNzJtWThzVlM1dUtEenFjTVNJZk9NV01HTWxDWjZT?=
 =?utf-8?B?UUs4eXhUNmhpdUFDRVNzTHA5cDlYSVl3aVpCU1ZRY0M5RDVKMmxPblBQeDJ0?=
 =?utf-8?B?Qlo1a3lSVmJiS0preE1PKzg2VmNVbjZCeXVSNmtjY1B2eUU1QktybVBwVXlF?=
 =?utf-8?B?b2dZaHpDU0ZHQ1JVQzA2VmZPaUZTb0Q4RFZ1L1RUNWpIWjh1bEwvRGdheFEw?=
 =?utf-8?B?OHE1dmU3eUpmRFN4QU5NMFh1SWVVZzFETlFiVnVqUU5iYUhydmkwV1RnVDQx?=
 =?utf-8?B?Wi84R1R4VVZCeVFvazJZSDE1ZGVtQnBOdGRJQXVRUGlDTVNpUGVyZ1J6OXFS?=
 =?utf-8?B?LzhiVGc5VDVQVHBBOUNZeCswNENLaS9TSGZsY2hKUTUwZzVRYVVuWFp3a3pa?=
 =?utf-8?B?S2RzNy9waHkzbmdZWFk5a3Y4QUNYMXE3U2dOMXRKQlhvTjhQWU9uYUFzQTZU?=
 =?utf-8?B?dXkwREhxdklmSllBNndCZDRZQWdLUUlMaWtURHBiU3VRTGIrU3g4RE43cGZZ?=
 =?utf-8?B?WW04R3hMc3grcHRjcFU2ZHFBYnQ3ZFNyVXEzQy9wc3pJSm81Z0lFNnFSeTRJ?=
 =?utf-8?B?WlgyVUtiTjJDeDZVVjZwRnJzc2VpV1MvSW02WjFIejc5c2hvcldSdlZzQ3dB?=
 =?utf-8?B?RnVRM3lZR0Y1bU1zaHdHeFVYYnRJZGMyRVpkVE1hOUNnd05tclJmdEVIckZY?=
 =?utf-8?B?a0FuVUNzalZpa2RjMDM3ZDd0MndLUndJVVF3Mk1RSTNEQTVqSGdRZTk4dXM2?=
 =?utf-8?B?T0ExSGVwQVVGUkpZYU9yczlQOFYzek1TaVZSRmFjRDd5dlBoZE5HcFdxdjRm?=
 =?utf-8?B?SXBRSjZZK3h0akRwN2RvZmUzWkxkYi9ZTzFrZlNFb1RPNnhRaGtpRHVwM0hm?=
 =?utf-8?B?dlh2T0lXcVIrSllFUzRjWTZFRnpscnpXN0lqTkR2ZTJINVlVODh2VnAraHJH?=
 =?utf-8?B?K3ByM3k5Yml5aUJPOWUxS3llcUcySmhnZGdtQ3pZVVZya01NZmF3aGRlVXpP?=
 =?utf-8?B?WWZuRGYwUmsvRFNoeVBUWjNEWTFaQytZMVZXOXZha2NpQWZwTHlxQXAzZVlG?=
 =?utf-8?B?MThWS3N3UGZGeVJ3ZlNxQlRDL291aWllZmhrK1JVZ2lIMzRPdHZ0V0Y0L3E3?=
 =?utf-8?B?OUtER1NBdUx5alRBRWJqb0QvYnF5RU5uOFYwNDM1VEpPd21WTEhjc0xnNlNn?=
 =?utf-8?Q?WV3K4sXpkvD6HFZz5XxmvJORC?=
Content-ID: <4784DBE88FFFD14C9BAC0A099B0421E1@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR19MB3769.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b2b5e5e3-72ac-4105-fea6-08daa50c5bbe
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Oct 2022 06:56:12.3155 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: d8lCrKzZRtQE9mRO7rOK+unjhBTnJQ83BoPU+J77ddL7TWHRgSFdhmYQ1Adb0G8GxDAAslVk8dIHoxlMrPrMeg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA0PR19MB4443
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
From: Sebastien Buisson via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Sebastien Buisson <sbuisson@ddn.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

R2Vycml0IGlzIGluIG1haW50ZW5hbmNlIHRoaXMgbW9ybmluZywgc2hvdWxkIGJlIGJhY2sgbGF0
ZXIgdG9kYXkuDQoNCj4gTGUgMyBvY3QuIDIwMjIgw6AgMDg6NTIsIMOFa2UgU2FuZGdyZW4gPGFr
ZS5zYW5kZ3JlbkBocGMybi51bXUuc2U+IGEgw6ljcml0IDoNCj4gDQo+IEhpIQ0KPiANCj4gSnVz
dCB0cnlpbmcgdG8gcHVzaCB0byByZXZpZXcsIGJ1dCBnZXQNCj4gPT09DQo+IHNzaDogY29ubmVj
dCB0byBob3N0IHJldmlldy53aGFtY2xvdWQuY29tIHBvcnQgMjk0MTg6IENvbm5lY3Rpb24gcmVm
dXNlZA0KPiBmYXRhbDogQ291bGQgbm90IHJlYWQgZnJvbSByZW1vdGUgcmVwb3NpdG9yeS4NCj4g
DQo+IFBsZWFzZSBtYWtlIHN1cmUgeW91IGhhdmUgdGhlIGNvcnJlY3QgYWNjZXNzIHJpZ2h0cw0K
PiBhbmQgdGhlIHJlcG9zaXRvcnkgZXhpc3RzLg0KPiA9PT0NCj4gDQo+IEl0J3MgYmVlbiBhIHdo
aWxlIHNpbmNlIEkgZGlkIHRoaXMgdGhlIGxhc3QgdGltZSBzbyBJIG1pZ2h0IGhhdmUgYmVlbiBr
aWNrZWQgb3V0Lg0KPiANCj4gLS0gDQo+IEFrZSBTYW5kZ3JlbiwgSFBDMk4sIFVtZWEgVW5pdmVy
c2l0eSwgUy05MDE4NyBVbWVhLCBTd2VkZW4NCj4gSW50ZXJuZXQ6IGFrZUBocGMybi51bXUuc2Ug
IE1vYmlsZTogKzQ2IDcwIDc3MTYxMzQgIEZheDogKzQ2IDkwLTU4MCAxNA0KPiBXV1c6IGh0dHA6
Ly93d3cuaHBjMm4udW11LnNlDQo+IF9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fDQo+IGx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QNCj4gbHVzdHJlLWRldmVs
QGxpc3RzLmx1c3RyZS5vcmcNCj4gaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dp
L2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnDQoNCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVs
QGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1
c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
