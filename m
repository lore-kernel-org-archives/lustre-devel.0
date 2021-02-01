Return-Path: <SRS0=Cg/e=HD=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MIME_HTML_MOSTLY,PDS_BAD_THREAD_QP_64,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CFD8C433DB
	for <lustre-devel@archiver.kernel.org>; Mon,  1 Feb 2021 18:18:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 803A664E50
	for <lustre-devel@archiver.kernel.org>; Mon,  1 Feb 2021 18:18:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 803A664E50
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 36EA621FBF3;
	Mon,  1 Feb 2021 10:18:56 -0800 (PST)
Received: from mx0a-002e3701.pphosted.com (mx0a-002e3701.pphosted.com
 [148.163.147.86])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CC0D321F910
 for <lustre-devel@lists.lustre.org>; Mon,  1 Feb 2021 10:18:54 -0800 (PST)
Received: from pps.filterd (m0150242.ppops.net [127.0.0.1])
 by mx0a-002e3701.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id
 111IGiDJ025488; Mon, 1 Feb 2021 18:18:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hpe.com;
 h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 mime-version; s=pps0720; bh=GcnNbz5I5k4flaYdkJTaYm1Jp6ZgotLMR5be9qgal74=;
 b=Bk6utyehxbHHPkiLl2jVp+YZ9tfRrVpNBn30IlLxE3mZ6/Ukv8bp+f9ELPDUR2Fz9ZJZ
 DhlcHwDBjx55BaJNkusWKRQexXHE6JsNKI0nPXb0gVdVW/g71j3UCLbmuwVRGAuST4Ks
 CYPiund/v6TciX45igeePsaqRXq7Q0dgcBcpFIZt01KWlH4sVjhq0wRmdSxtDri/NAFb
 +VwE6Ewh7q6YTJxM6tSvcBXP0I9ozBGeASRtr9N7S89dutIfChXiJZDXXMH91PahZvSk
 NBZTbWnkP9QfFYS+Gac1cND92F+XLOJT/+KTR+sLOR2zuHKdBQ2F3UllMzy5G1q3668B Ww== 
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com [15.233.44.26])
 by mx0a-002e3701.pphosted.com with ESMTP id 36dgwubx9t-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Mon, 01 Feb 2021 18:18:52 +0000
Received: from G2W6309.americas.hpqcorp.net (g2w6309.austin.hp.com
 [16.197.64.51])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
 (No client certificate requested)
 by g2t2353.austin.hpe.com (Postfix) with ESMTPS id 696B38C;
 Mon,  1 Feb 2021 18:18:51 +0000 (UTC)
Received: from G9W8453.americas.hpqcorp.net (2002:10d8:a0d3::10d8:a0d3) by
 G2W6309.americas.hpqcorp.net (2002:10c5:4033::10c5:4033) with Microsoft SMTP
 Server (TLS) id 15.0.1497.2; Mon, 1 Feb 2021 18:18:50 +0000
Received: from NAM10-DM6-obe.outbound.protection.outlook.com (15.241.52.12) by
 G9W8453.americas.hpqcorp.net (16.216.160.211) with Microsoft SMTP
 Server
 (TLS) id 15.0.1497.2 via Frontend Transport; Mon, 1 Feb 2021 18:18:50 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=HfVTFQggoRn/1FbkxciVeacYnNgpEQ9CsXdzurhj6cK8LMGGvNHTSi6d9qaCMTZZeKdj7tnhshm07Ig7yqOUdotZhEcaDMiqTYTtit+NVBqumP6rACBMgh+aJS+s/IsjG0vehEau1DR/NNPhtQENPxNRCkriswv4KIkYWGaganmBzHZZxP76a39qeFh4NMRAkQFNzQcQw37owUkdipc7Kmn97hOvrJOHBW0xl6S3bpgfjh6OP0YH//yTGWFYJc/ac3oa8xCoi2vZm/PBAAoJKbG+p0caljlbpqGuVEYD64MUW3Ux7hTLYVuNcUB16X0tvu+6Coqk+FjUuE4wVL77JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=x77HA6VqeP80YmrZ7PwbIiD5vNmI68EoPIdJ7YFNO6U=;
 b=D3cbGJpmYhwy7t0eidtza8DfuTah+x7dr1rfELfEfqtEdIgrJuzX760S3klXVBfMkh+rl5bjitd92aTiIB1dXOcge5oNv2/8ZnV9e3rPftDehdv+xrM/zbdmmI0jbFeZGaztf1tTU1hZmN61GsJyKUd/pHG3+zcWlweH14bXvwPCK/2SFPdpCG45ynuDYRljBs3PthTEp9TLYAOxKb+etYBOVVOLMWZRwdi1bPv/1j2NmCiDo/li2yOHHMQPnK4jqh7Zcy9pMiv0MSRGxNsXDXCAHphwjLLVCLOjSgh4OUEpNGd2RmJl/nFN0mi2fCYyCqwHg1B/Hveet7TH9/fHLw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=hpe.com; dmarc=pass action=none header.from=hpe.com; dkim=pass
 header.d=hpe.com; arc=none
Received: from AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
 (2a01:111:e400:7428::7) by AT5PR8401MB0435.NAMPRD84.PROD.OUTLOOK.COM
 (2a01:111:e400:741d::9) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3805.17; Mon, 1 Feb
 2021 18:18:49 +0000
Received: from AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::d66:6ea0:eddd:a876]) by AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::d66:6ea0:eddd:a876%8]) with mapi id 15.20.3805.027; Mon, 1 Feb 2021
 18:18:49 +0000
From: "Spitz, Cory James" <cory.spitz@hpe.com>
To: Sudheendra Sampath <sudheendra.sampath@gmail.com>, "Degremont, Aurelien"
 <degremoa@amazon.com>
Thread-Topic: [lustre-devel] Lustre log question(s)
Thread-Index: AQHW9bYyEoSdiRx19UKdt54umaBn5ao+VSoAgAIUJ4CAAze68g==
Date: Mon, 1 Feb 2021 18:18:48 +0000
Message-ID: <AT5PR8401MB105937EE4A01282B931D06FF85B69@AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM>
References: <CABnqofzHf0GdzqiXebSzbkDHHoGwxoAyCnja7_=YqWGVOnn7jA@mail.gmail.com>
 <2BA3D230-5DA3-4323-A7F0-2CAA21E7782F@amazon.com>,
 <CABnqofyAXbb1nwkerUDAB8cdpY+ieQDoQ6MOH77mJk_0cKbbiw@mail.gmail.com>
In-Reply-To: <CABnqofyAXbb1nwkerUDAB8cdpY+ieQDoQ6MOH77mJk_0cKbbiw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: gmail.com; dkim=none (message not signed)
 header.d=none;gmail.com; dmarc=none action=none header.from=hpe.com;
x-originating-ip: [207.153.28.122]
x-ms-publictraffictype: Email
x-ms-office365-filtering-ht: Tenant
x-ms-office365-filtering-correlation-id: 56593d10-1ec1-4929-c871-08d8c6ddd251
x-ms-traffictypediagnostic: AT5PR8401MB0435:
x-microsoft-antispam-prvs: <AT5PR8401MB0435E77DFF2A9FF5C02E8FBE85B69@AT5PR8401MB0435.NAMPRD84.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: NLrraQ87PiyA3nkWLdPa0C0gHn7pTu5/j0Cl+Jl4uxeiC6ItFi6PJQ7jzx94n8b/tvdNgwaQqnuyq2H1dbvUhDIuF3yIS8GbNfmvyuc6bmWZnLskKDydTQqjHHh7dYqtTIeA020N43q30mw6KKDCYgReL3hHannyM/07f3WtHXcVPEsEpssbVVjBJJAmXDbzQPkHwRV/xDfsC6LE2YDKSKwxqEi6zSxscbKLD7sF94R2hLjlaMS7jOOuRgd7XCUIgC5w1W9sKEB9b1S3TLmEJ/jJIgW/HMqcvyBi+UgH5CueyTWyRchuoO0LnDL2T8hI6KbG4UMeqCOIOG1HqsjL3JqBnqtz6le4AXMRNWh3AbSxZXzgGc48l18IhdBD+1+WNZ66fZu2hmavHbFgVip+6KzBPHTQFQEDvQAgd7/gsDB38NvWvUqRHn7zlFCwivnQTjjIeetNojnuC6btCAtdXkZUx67SKKFWj3GfXo7ujBuuOvFfDDNJCpK2eRjAK7ZIgl+gZZcwDMYgRb6I+LoNgkOmFijUQLn0Zf1Yjiy+xm5M3Os2q29NUn2BxKGkkxbJVnNXTJAaC6M9JypECYUuHywWiYGtRt4MoLV3GiZjO0rUQRetTVmIh3cj+5GZgIE7gcgIVZ7JfsqJxZg2birxKg==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM; PTR:; CAT:NONE;
 SFS:(376002)(346002)(39860400002)(366004)(396003)(136003)(8676002)(91956017)(186003)(76116006)(6506007)(478600001)(66946007)(2906002)(8936002)(7696005)(71200400001)(55016002)(53546011)(9686003)(26005)(4326008)(316002)(66446008)(52536014)(66476007)(83380400001)(5660300002)(66574015)(966005)(33656002)(86362001)(110136005)(66556008)(64756008)(13693001);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata: =?iso-8859-1?Q?alat1nXX0vtjQmg0BHVD5yKNGgb8wRBL1HjK5S89yePBHU+SzpFlNywrAp?=
 =?iso-8859-1?Q?iXvnYfJoXP4BbYAPVeUzpBbLbyxcCHBRydMhQVpoWCGicdvRD9II+AWUEV?=
 =?iso-8859-1?Q?BvGWy6A4L6IMnD7C3VFIPj+YLCK9A1U+5skHbPcteLmIDeoECIkhYbL9Ti?=
 =?iso-8859-1?Q?IL2sgPVczT70HHo/aw+o41b81SBWGs5BNsVE93lFbYLwrNn76sBReeHPex?=
 =?iso-8859-1?Q?R00N5EHPI+8sxf1MzaMBMM0qQxBl3Rmd+WMuJY25JulYb8NYscLaHZLXmf?=
 =?iso-8859-1?Q?u7+rzTxuGSUNWnIsrIMuR7bXzEFLoIOIwbDEk5RR0rfe7XoEkkWaRSK3Jp?=
 =?iso-8859-1?Q?naQe9gzZS+/Sp7c+m1YaItrtZ8VYRRmBCWnZddVW/ACOm5C3beCM/h3ZJF?=
 =?iso-8859-1?Q?Fwe8Teosf4exdEcwPxx3PBBJNDYPjAwOurNSt/p23OG1JDyyIhO5oD6Kie?=
 =?iso-8859-1?Q?vTopGzpCG/1rTjM3kuECAXzImL0ojXGNtmaIOzm5JDs1hu7RAXhFYH/660?=
 =?iso-8859-1?Q?oFF9ZCruPOLTJM1P93RuzJ1kIvquTD1gnZVQ27dYUf9n5ah1Jh2N6f8Q9V?=
 =?iso-8859-1?Q?sq/zlANQM7kdw6Egm56C3oMe9rSxZKt3Yj4Rad6k9TvQGsg3WwKPksdYaJ?=
 =?iso-8859-1?Q?pj0D+XqkhEQgFk/HxTSylJ5IweakeUMAviVws628C9MVrA0WPaGpJqObGO?=
 =?iso-8859-1?Q?WL6cg8CgvtSaqI1jGIS6bbEvQ+mDRT8TM65cnBlBBAWkhMT+u5XE0KJedJ?=
 =?iso-8859-1?Q?PpYM4+Wf+hbrWQ/Av7WeQujYuDvF+qi8jn/wpCxQ7fgyk0sqpDwtYPIgos?=
 =?iso-8859-1?Q?pEeiCBi22O4fonBgts+R4moY+Pxz662r9ZMfHbUena0Fm8u5Btp3Afd4ZA?=
 =?iso-8859-1?Q?bRgnwsYbH4b1362HJxXgCt3FzaxG+uiBklQGJ55sETx2ycsXXOTScALDd2?=
 =?iso-8859-1?Q?sOUpH1aKhahiY+7v++yhtc8F+SZFCMAcnY1TnIO73eowkdZoy75ZYNrxTa?=
 =?iso-8859-1?Q?zTAF9Kzu6b7aRFoqK2qMb8zglW4EpqCrMu1O3pLXD60K8tLaWNIIA6uiwf?=
 =?iso-8859-1?Q?67QbMN5ILV+rDEo4tbMwiEN7fCeLR2uw1bSiABDaTL5GIriGY76RYOWzBr?=
 =?iso-8859-1?Q?Z6r/fo3w=3D=3D?=
x-ms-exchange-transport-forked: True
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
X-MS-Exchange-CrossTenant-Network-Message-Id: 56593d10-1ec1-4929-c871-08d8c6ddd251
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Feb 2021 18:18:48.9823 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 105b2061-b669-4b31-92ac-24d304d195dc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: bTPrpKfIPIremsyc6tilKkb7XYtSy5LFBtx+CYC3lBRlRdRwkWDxnFL8iHdwYB9/q6DxBd4jU1v38ZNwuLfccA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AT5PR8401MB0435
X-OriginatorOrg: hpe.com
X-Proofpoint-UnRewURL: 0 URL was un-rewritten
MIME-Version: 1.0
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.369, 18.0.737
 definitions=2021-02-01_06:2021-01-29,
 2021-02-01 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 malwarescore=0 adultscore=0
 bulkscore=0 priorityscore=1501 impostorscore=0 clxscore=1011 mlxscore=0
 suspectscore=0 spamscore=0 phishscore=0 mlxlogscore=999 lowpriorityscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2009150000
 definitions=main-2102010095
Subject: Re: [lustre-devel] Lustre log question(s)
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============4732465353384658088=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4732465353384658088==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_AT5PR8401MB105937EE4A01282B931D06FF85B69AT5PR8401MB1059_"

--_000_AT5PR8401MB105937EE4A01282B931D06FF85B69AT5PR8401MB1059_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> I am trying to get a 30,000 ft overview of how lustre replay/recovery wor=
ks

This old slide deck might be useful to you:
https://wiki.lustre.org/images/0/00/A_Deep_Dive_into_Lustre_Recovery_Mechan=
isms.pdf

Granted, it may not be 100% correct any longer.

-Cory

On 1/30/21, 11:08 AM, "lustre-devel" <lustre-devel-bounces@lists.lustre.org=
> wrote:

Thank you for the explanation on LLOG and changelog.  With respect to the f=
ollowing statement :

>> Lustre has its own mechanisms to guarantee transaction are committed to =
disk and handle crash. Basicly, I/O are not acknowledge to Lustre clients b=
efore the data is actually on disk. In case of server crash, the Lustre cli=
ent will replay all non-acknowledge I/Os to ensure none of them are lost.

For example:

Let us say that I have 4 clients (cli1, cli2, cli3 and cli4) and all are wr=
iting and reading data.  I have 1 host with 4 disks (2 OSTs, 1 MDT, 1 MGT).
1.       cli1 issues a directory remove (rm -rf /mnt/lustre/dir1)
2.       cli1 loses connection with Lustre targets.
3.       cli2 wants to now create a file under /mnt/lustre/dir1/file100 and=
 write some data to file100
All of these are happening in parallel.
=B7         Does cli2 get an error that /mnt/lustre/dir1 has been removed a=
nd it has to first issue additional I/O to create /mnt/lustre/dir1 before r=
eissuing the I/O to write file100 ?
=B7         If a transaction from cli2 happens before cli1, then this would=
 lead to data lost situation for cli2, if cli2 tries to read/write data fro=
m/to file100 after sometime.
=B7         What is the role of last_rcvd file in this entire picture ?
I am trying to get a 30,000 ft overview of how lustre replay/recovery works.

Thanks again and appreciate your timely response.

On Fri, Jan 29, 2021 at 1:22 AM Degremont, Aurelien <degremoa@amazon.com<ma=
ilto:degremoa@amazon.com>> wrote:
Hi,

This is not totally correct.

First, LLOG is the underlying technology used to store and handle Lustre Ch=
angelogs. But LLOG is used for other Lustre mechanisms, like lustre configu=
ration.
Second, Changelog is similar to an audit feature. Changelog only logs diffe=
rent filesystem change, mostly metadata change, but definitely not the file=
 content change. They don't play a role at all in transaction or failure re=
covery. This is only an admin feature.

At the end, indeed ZIL cannot be used and Lustre has its own mechanisms to =
guarantee transaction are committed to disk and handle crash. Basicly, I/O =
are not acknowledge to Lustre clients before the data is actually on disk. =
In case of server crash, the Lustre client will replay all non-acknowledge =
I/Os to ensure none of them are lost.

Changelog is not needed in your case.

Aur=E9lien

De : lustre-devel <lustre-devel-bounces@lists.lustre.org<mailto:lustre-deve=
l-bounces@lists.lustre.org>> au nom de Sudheendra Sampath <sudheendra.sampa=
th@gmail.com<mailto:sudheendra.sampath@gmail.com>>
Date : jeudi 28 janvier 2021 =E0 21:43
=C0 : "lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>"=
 <lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Objet : [EXTERNAL] [lustre-devel] Lustre log question(s)


CAUTION: This email originated from outside of the organization. Do not cli=
ck links or open attachments unless you can confirm the sender and know the=
 content is safe.

Hi,

I am trying to evaluate osd-zfs based MDS and OST deployment on a 2 node se=
tup.

I have the following questions about Lustre log:
1.       Is changelog and llog both the same, in the sense are they synonym=
ous with each other?
2.       I understand that ZIL is currently not supported in Lustre version=
 2.12.2.  My question is :
1.       My understanding is that transactions (in general) need some loggi=
ng mechanism for it to work in 'all or none' scenarios.  Please correct me =
if my understanding is incorrect.   I understand that changelog has to be e=
nabled so that filesystem changes are recorded to be replayed after a crash=
.  How does Lustre transactions work if there is no intent log/changelog ?
2.       Does it mean that if changelog is NOT enabled and there is a crash=
, we risk losing all changes/updates to the filesystem ?
Appreciate your timely response and Thank you for your help.

--
Regards

Sudheendra Sampath


--
Regards

Sudheendra Sampath

--_000_AT5PR8401MB105937EE4A01282B931D06FF85B69AT5PR8401MB1059_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
span.EmailStyle20
	{mso-style-type:personal-reply;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
/* List Definitions */
@list l0
	{mso-list-id:100994177;
	mso-list-template-ids:-456783150;}
@list l0:level1
	{mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level2
	{mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level3
	{mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level4
	{mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level5
	{mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level6
	{mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level7
	{mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level8
	{mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l0:level9
	{mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;}
@list l1
	{mso-list-id:493305325;
	mso-list-template-ids:-869521590;}
@list l1:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7 ;
	mso-level-tab-stop:.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Symbol;}
@list l1:level2
	{mso-level-number-format:bullet;
	mso-level-text:o;
	mso-level-tab-stop:1.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:"Courier New";
	mso-bidi-font-family:"Times New Roman";}
@list l1:level3
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7 ;
	mso-level-tab-stop:1.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Wingdings;}
@list l1:level4
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7 ;
	mso-level-tab-stop:2.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Wingdings;}
@list l1:level5
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7 ;
	mso-level-tab-stop:2.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Wingdings;}
@list l1:level6
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7 ;
	mso-level-tab-stop:3.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Wingdings;}
@list l1:level7
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7 ;
	mso-level-tab-stop:3.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Wingdings;}
@list l1:level8
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7 ;
	mso-level-tab-stop:4.0in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Wingdings;}
@list l1:level9
	{mso-level-number-format:bullet;
	mso-level-text:\F0A7 ;
	mso-level-tab-stop:4.5in;
	mso-level-number-position:left;
	text-indent:-.25in;
	mso-ansi-font-size:10.0pt;
	font-family:Wingdings;}
ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
--></style>
</head>
<body lang=3D"EN-US" link=3D"blue" vlink=3D"purple" style=3D"word-wrap:brea=
k-word">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">&gt; I am trying to get a 30,000 ft overview of how =
lustre replay/recovery works<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">This old slide deck might be useful to you:<o:p></o:=
p></p>
<p class=3D"MsoNormal">https://wiki.lustre.org/images/0/00/A_Deep_Dive_into=
_Lustre_Recovery_Mechanisms.pdf<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Granted, it may not be 100% correct any longer.<o:p>=
</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">-Cory<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">On 1/30/21, 11:08 AM, &qu=
ot;lustre-devel&quot; &lt;lustre-devel-bounces@lists.lustre.org&gt; wrote:<=
o:p></o:p></p>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Thank you for the explana=
tion on LLOG and changelog.&nbsp; With respect to the following statement :=
<o:p></o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><b>&gt;&gt; Lustre has it=
s own mechanisms to guarantee transaction are committed to disk and handle =
crash. Basicly, I/O are not acknowledge to Lustre clients before the data i=
s actually on disk. In case of server crash,
 the Lustre client will replay all non-acknowledge I/Os to ensure none of t=
hem are lost.</b><o:p></o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">For example:<o:p></o:p></=
p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Let us say that I have 4 =
clients (cli1, cli2, cli3 and cli4) and all are writing and reading data.&n=
bsp; I have 1 host with 4 disks (2 OSTs, 1 MDT, 1 MGT).&nbsp;<o:p></o:p></p=
>
</div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:1.0in;text-indent:-.25in;mso-list:l0 level1 lfo1">
<![if !supportLists]><span style=3D"mso-list:Ignore">1.<span style=3D"font:=
7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>cli1 issues a directory remove (rm -rf /mnt/lustre/=
dir1)<o:p></o:p></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:1.0in;text-indent:-.25in;mso-list:l0 level1 lfo1">
<![if !supportLists]><span style=3D"mso-list:Ignore">2.<span style=3D"font:=
7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>cli1 loses connection with Lustre targets.<o:p></o:=
p></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:1.0in;text-indent:-.25in;mso-list:l0 level1 lfo1">
<![if !supportLists]><span style=3D"mso-list:Ignore">3.<span style=3D"font:=
7.0pt &quot;Times New Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><![endif]>cli2 wants to now create a file under /mnt/lustre/d=
ir1/file100 and write some data to file100<o:p></o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">All of these are happenin=
g in parallel.&nbsp;<o:p></o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:1.0in;text-indent:-.25in;mso-list:l1 level1 lfo2">
<![if !supportLists]><span style=3D"font-size:10.0pt;font-family:Symbol"><s=
pan style=3D"mso-list:Ignore">=B7<span style=3D"font:7.0pt &quot;Times New =
Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>Does cli2 get an error that /mnt/lustre/dir1=
 has been removed and it has to first issue additional I/O to create /mnt/l=
ustre/dir1 before reissuing the I/O to write file100 ?<o:p></o:p></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:1.0in;text-indent:-.25in;mso-list:l1 level1 lfo2">
<![if !supportLists]><span style=3D"font-size:10.0pt;font-family:Symbol"><s=
pan style=3D"mso-list:Ignore">=B7<span style=3D"font:7.0pt &quot;Times New =
Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>If a transaction from cli2 happens before cl=
i1, then this would lead to data lost situation for cli2, if cli2 tries to =
read/write data from/to file100 after sometime.<o:p></o:p></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:1.0in;text-indent:-.25in;mso-list:l1 level1 lfo2">
<![if !supportLists]><span style=3D"font-size:10.0pt;font-family:Symbol"><s=
pan style=3D"mso-list:Ignore">=B7<span style=3D"font:7.0pt &quot;Times New =
Roman&quot;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]>What is the role of last_rcvd file in this e=
ntire picture ?<o:p></o:p></p>
</div>
</div>
<div>
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">I am trying to get a 30,0=
00 ft overview of how lustre replay/recovery works.<o:p></o:p></p>
</div>
</div>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Thanks again and apprecia=
te your timely response.<o:p></o:p></p>
</div>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">On Fri, Jan 29, 2021 at 1=
:22 AM Degremont, Aurelien &lt;<a href=3D"mailto:degremoa@amazon.com">degre=
moa@amazon.com</a>&gt; wrote:<o:p></o:p></p>
</div>
<blockquote style=3D"border:none;border-left:solid #CCCCCC 1.0pt;padding:0i=
n 0in 0in 6.0pt;margin-left:4.8pt;margin-right:0in">
<div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
Hi,<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
&nbsp;<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
This is not totally correct.<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
&nbsp;<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
First, LLOG is the underlying technology used to store and handle Lustre Ch=
angelogs. But LLOG is used for other Lustre mechanisms, like lustre configu=
ration.<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
Second, Changelog is similar to an audit feature. Changelog only logs diffe=
rent filesystem change, mostly metadata change, but definitely not the file=
 content change. They don't play a role at all in transaction or failure re=
covery. This is only an admin feature.<span lang=3D"FR"><o:p></o:p></span><=
/p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
&nbsp;<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
At the end, indeed ZIL cannot be used and Lustre has its own mechanisms to =
guarantee transaction are committed to disk and handle crash. Basicly, I/O =
are not acknowledge to Lustre clients before the data is actually on disk. =
In case of server crash, the Lustre
 client will replay all non-acknowledge I/Os to ensure none of them are los=
t.<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
&nbsp;<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
Changelog is not needed in your case.<span lang=3D"FR"><o:p></o:p></span></=
p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
&nbsp;<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
Aur=E9lien<span lang=3D"FR"><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:.5in">
&nbsp;<span lang=3D"FR"><o:p></o:p></span></p>
<div style=3D"border:none;border-top:solid #B5C4DF 1.0pt;padding:3.0pt 0in =
0in 0in">
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<b><span lang=3D"FR" style=3D"font-size:12.0pt;color:black">De&nbsp;: </spa=
n></b><span lang=3D"FR" style=3D"font-size:12.0pt;color:black">lustre-devel=
 &lt;<a href=3D"mailto:lustre-devel-bounces@lists.lustre.org" target=3D"_bl=
ank">lustre-devel-bounces@lists.lustre.org</a>&gt; au nom
 de Sudheendra Sampath &lt;<a href=3D"mailto:sudheendra.sampath@gmail.com" =
target=3D"_blank">sudheendra.sampath@gmail.com</a>&gt;<br>
<b>Date&nbsp;: </b>jeudi 28 janvier 2021 =E0 21:43<br>
<b>=C0&nbsp;: </b>&quot;<a href=3D"mailto:lustre-devel@lists.lustre.org" ta=
rget=3D"_blank">lustre-devel@lists.lustre.org</a>&quot; &lt;<a href=3D"mail=
to:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-devel@lists.lust=
re.org</a>&gt;<br>
<b>Objet&nbsp;: </b>[EXTERNAL] [lustre-devel] Lustre log question(s)</span>=
<span lang=3D"FR"><o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">&nbsp;<o:p></o:p></span></p>
</div>
<div>
<table class=3D"MsoNormalTable" border=3D"0" cellspacing=3D"0" cellpadding=
=3D"0" width=3D"625" style=3D"width:468.8pt;margin-left:71.4pt;border-colla=
pse:collapse">
<tbody>
<tr style=3D"height:15.25pt">
<td width=3D"625" valign=3D"top" style=3D"width:468.8pt;border:solid #ED7D3=
1 1.5pt;padding:0in 5.4pt 0in 5.4pt;height:15.25pt">
<p><strong><span style=3D"font-family:&quot;Calibri&quot;,sans-serif;color:=
black;background:#FFFF99">CAUTION</span></strong><span style=3D"color:black=
;background:#FFFF99">: This email originated from outside of the organizati=
on. Do not click links or open attachments unless
 you can confirm the sender and know the content is safe.</span><o:p></o:p>=
</p>
</td>
</tr>
</tbody>
</table>
</div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR" style=3D"color:white">&nbsp;</span><span lang=3D"FR"><o:p=
></o:p></span></p>
<div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">Hi, <o:p></o:p></span></p>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">&nbsp;<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">I am trying to evaluate osd-zfs based MDS and OST deploym=
ent on a 2 node setup.<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">&nbsp;<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">I have the following questions about Lustre log:<o:p></o:=
p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:107.4pt">
<span lang=3D"FR">1.</span><span lang=3D"FR" style=3D"font-size:7.0pt;font-=
family:&quot;Times New Roman&quot;,serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;
</span><b><span lang=3D"FR">Is changelog and llog both the same, in the sen=
se are they synonymous with each other?</span></b><span lang=3D"FR"><o:p></=
o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:107.4pt">
<span lang=3D"FR">2.</span><span lang=3D"FR" style=3D"font-size:7.0pt;font-=
family:&quot;Times New Roman&quot;,serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;
</span><span lang=3D"FR">I understand that ZIL is currently not supported i=
n Lustre version 2.12.2.&nbsp; My question is :&nbsp;&nbsp;
<o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:143.4pt">
<span lang=3D"FR">1.</span><span lang=3D"FR" style=3D"font-size:7.0pt;font-=
family:&quot;Times New Roman&quot;,serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;
</span><span lang=3D"FR">My understanding is that transactions (in general)=
 need some logging mechanism for it to work in 'all or none' scenarios.&nbs=
p; Please correct me if my understanding is incorrect.&nbsp; &nbsp;I unders=
tand that changelog has to be enabled so that filesystem
 changes are recorded to be replayed after a crash.&nbsp; <b>How does Lustr=
e transactions work if there is no intent log/changelog ?</b><o:p></o:p></s=
pan></p>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:143.4pt">
<span lang=3D"FR">2.</span><span lang=3D"FR" style=3D"font-size:7.0pt;font-=
family:&quot;Times New Roman&quot;,serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;
</span><span lang=3D"FR">Does it mean that if changelog is NOT enabled and =
there is a crash, we risk losing all changes/updates to the filesystem ?<o:=
p></o:p></span></p>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">Appreciate your timely response and Thank you for your he=
lp.<o:p></o:p></span></p>
</div>
</div>
<div>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">&nbsp;<o:p></o:p></span></p>
</div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">-- <o:p></o:p></span></p>
<div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:auto;mso-margin-bottom-a=
lt:auto;margin-left:71.4pt">
<span lang=3D"FR">Regards<br>
<br>
Sudheendra Sampath<o:p></o:p></span></p>
</div>
</div>
</div>
</div>
</div>
</div>
</blockquote>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><br clear=3D"all">
<o:p></o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">-- <o:p></o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Regards<br>
<br>
Sudheendra Sampath<o:p></o:p></p>
</div>
</div>
</body>
</html>

--_000_AT5PR8401MB105937EE4A01282B931D06FF85B69AT5PR8401MB1059_--

--===============4732465353384658088==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4732465353384658088==--
