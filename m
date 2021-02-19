Return-Path: <SRS0=W2nY=HV=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.4 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	PDS_BAD_THREAD_QP_64,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A5DEC433E0
	for <lustre-devel@archiver.kernel.org>; Fri, 19 Feb 2021 14:17:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2552864EB7
	for <lustre-devel@archiver.kernel.org>; Fri, 19 Feb 2021 14:17:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2552864EB7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1392B21F7E9;
	Fri, 19 Feb 2021 06:17:36 -0800 (PST)
Received: from mx0b-002e3701.pphosted.com (mx0b-002e3701.pphosted.com
 [148.163.143.35])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A564321F79F
 for <lustre-devel@lists.lustre.org>; Fri, 19 Feb 2021 06:17:33 -0800 (PST)
Received: from pps.filterd (m0150245.ppops.net [127.0.0.1])
 by mx0b-002e3701.pphosted.com (8.16.0.43/8.16.0.43) with SMTP id
 11JEE5C8012904; Fri, 19 Feb 2021 14:17:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hpe.com;
 h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 mime-version; s=pps0720; bh=8Rgyd26n2xmAJN7VeP7WBRyxvJyHU1vJHBpwUD75Hcg=;
 b=VMp66miOL22YwRGfG/5Ik/btqwTGKedZ/sjh2GO9EKmocX1htMVRl4GynR6WUFEvajUN
 v4vlrrbjkwJ8wZFWD2OJ5++S6L6TUqmM6G/czFW8325MKimUNiBO4SPDZOVTn2/Jw8zW
 CPm59RiQiQl4MD2Jh0isSUrvLhuI3ZQOpDTvASXeKPtpnsFUCUr9UsPPOCJ6qED3ILme
 JtuBeVrv7oB9dzBVuHPheKmy4/K3Tk6iXU6JTWlAQcuTbbL1Dk8gosiikrANRSqnQwNn
 icRufqP3IF9EVUMBf0I6VRRJyWCnJO1OtaexPAVhvSEHAi32DepIrGF00jOxQl+CSvqO cg== 
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com
 [15.241.140.78])
 by mx0b-002e3701.pphosted.com with ESMTP id 36sqk6amv3-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
 Fri, 19 Feb 2021 14:17:32 +0000
Received: from G2W6310.americas.hpqcorp.net (g2w6310.austin.hp.com
 [16.197.64.52])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
 (No client certificate requested)
 by g4t3425.houston.hpe.com (Postfix) with ESMTPS id BFD9892;
 Fri, 19 Feb 2021 14:17:31 +0000 (UTC)
Received: from G2W6310.americas.hpqcorp.net (2002:10c5:4034::10c5:4034) by
 G2W6310.americas.hpqcorp.net (2002:10c5:4034::10c5:4034) with Microsoft SMTP
 Server (TLS) id 15.0.1497.2; Fri, 19 Feb 2021 14:17:31 +0000
Received: from NAM11-CO1-obe.outbound.protection.outlook.com (15.241.52.13) by
 G2W6310.americas.hpqcorp.net (16.197.64.52) with Microsoft SMTP
 Server (TLS)
 id 15.0.1497.2 via Frontend Transport; Fri, 19 Feb 2021 14:17:31 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Dau5BnU7uciT5aypbPvTqAJwMExzrqnX5q1Tn08MuL6/9ei1S7WSPGDylGviiiNS+ntEdvsbDIErpZouNSSzL3YDzLI56pefEpyRmsV8HMO85N5Md569HFSswLpeLRERZLvKdpLV/rhA08SCYBkDUOE1ePKhupSwY4PIxbyPqagfUTICiEIDioVO2D/xbILiCrFiNQXLutahedBN9v837PhUhlydL0YdYQKismqxxApZ/SwnT9p80nR0PX5y26wcFnDSEozkFzl6C5U8dZImDReoT7VksLuYpoxxtTpzsi1Pdwy8J3JjWfmDzSp81NKOv/HpkC1Kry0jUhRXeKlLrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8Rgyd26n2xmAJN7VeP7WBRyxvJyHU1vJHBpwUD75Hcg=;
 b=MZwIPNu/pjOmbwZjMUApO0TUzCtNQKDLXsBqKDK7nB4yr3PJas7n2pMRO/zArHPf9Yx5EpW0L9yDLa8PBIT+SFiNir9G2LFQOUWk/QzCtOln9T/40mhxhht8X6uHO4Ip7xK2BnKITHRUyT3SA5MFGjeZONvu0F4nt/b5rT/Fiw/RkNhcNPLy36u3zXbWVTEt5l1+BI98YBHOO9LvyLQ139L8rjeRnmb3u4kfczv7R+l6uhKeN5rc5x7Qg81XrY2tWFGwL2LMu2c1wMAfKhcDtoOdtGet4PUTzTd6E9AC7uWHPexKtY5jmPdhIW1CoMc9/MCsB6eLz7hJuSvly133DQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=hpe.com; dmarc=pass action=none header.from=hpe.com; dkim=pass
 header.d=hpe.com; arc=none
Received: from AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
 (2a01:111:e400:7428::7) by AT5PR8401MB0484.NAMPRD84.PROD.OUTLOOK.COM
 (2a01:111:e400:741d::22) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3868.28; Fri, 19 Feb
 2021 14:17:30 +0000
Received: from AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::41f0:4231:a050:21e1]) by AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::41f0:4231:a050:21e1%11]) with mapi id 15.20.3868.028; Fri, 19 Feb
 2021 14:17:30 +0000
From: "Spitz, Cory James" <cory.spitz@hpe.com>
To: Christian Kuntz <c.kuntz@opendrives.com>, Andreas Dilger
 <adilger@whamcloud.com>
Thread-Topic: [lustre-devel] Testing 2.14 on Debian + ZFS
Thread-Index: AQHXAZPuzpJQr94H7UCf9TZElpcgRKpdye6AgAFxOACAAFU28A==
Date: Fri, 19 Feb 2021 14:17:29 +0000
Message-ID: <AT5PR8401MB10590B46FE66B8103C91D04F85849@AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM>
References: <CANdLGj7=6X1ixcyNOguUAzxTTnegD3h2zfgaEso+Fv5E7YejVA@mail.gmail.com>
 <477F0D07-A7E1-488A-8E06-FE6C2E748FE1@whamcloud.com>,
 <CANdLGj7o4yJf3byyM4LaAm+ZfNkAswTjU+HSUeK2yK+Yw4cvVg@mail.gmail.com>
In-Reply-To: <CANdLGj7o4yJf3byyM4LaAm+ZfNkAswTjU+HSUeK2yK+Yw4cvVg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: opendrives.com; dkim=none (message not signed)
 header.d=none;opendrives.com; dmarc=none action=none header.from=hpe.com;
x-originating-ip: [71.203.47.65]
x-ms-publictraffictype: Email
x-ms-office365-filtering-ht: Tenant
x-ms-office365-filtering-correlation-id: 2211b50a-5b73-4c23-93d9-08d8d4e1178c
x-ms-traffictypediagnostic: AT5PR8401MB0484:
x-microsoft-antispam-prvs: <AT5PR8401MB04844E5985DFA1A451E93F5B85849@AT5PR8401MB0484.NAMPRD84.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: oE545hUJWjpjPe4vwnIp+qTKriviyik1IVkDGPShxkme+PThKcY49QQKNMDypfr+w4oyZJAKdc/D1yBvDz9ohX/unTkwP15pEcMC1BcZiKARRr7n7atRPJUI3BWvomOLYwJbhGCKKPWHjmSsfr6t/eYkdEyTsXxsXLPnFdY6V1HjnVQbt11T8+/gFqLfMLCBvJn5Ljx0CXxnZYDEekCOyLtrdXONUalvF4NUWvvGyxY+YZ61Pe0UudLdMMwfPAZylEMwgjWWl3LuC7R+OOGljnJk5r2lt5qJsQBifkQBVPa14G7ScSLSWEH607xMWVs3zHo0QcsY1dg8HwjVySSNzFJB2SmB39t/e4zYsPC9KKC3Gm6l15oA4PSINhIfg5hXCLRdfQVKs81g+lU8O3yRmOkmpDWntUvfL432BamLm5lBK+iYVQUuUR24nY6bnSQAu6rldPFk5o5VlsM73RSBX+9wSNYdCeNQqo1HX3jQSeoak1ifgVHq28IsT2EU/eoEv7Hi/bBsczQqIgYzl1ooTmnHRPPef3AVjIC+MJ8Iy+RFIdfkwN1oKmEUE3sEtOHXnKJlYND5kXGi4neVXcC9Fw==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM; PTR:; CAT:NONE;
 SFS:(396003)(366004)(39860400002)(376002)(346002)(136003)(33656002)(316002)(55016002)(186003)(71200400001)(110136005)(64756008)(66556008)(26005)(66946007)(66476007)(83380400001)(4326008)(478600001)(2906002)(9686003)(53546011)(52536014)(6506007)(7696005)(8936002)(8676002)(86362001)(66446008)(5660300002)(76116006)(13693001);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?uZCdSpZ5HXwyc1zlsEgY3QGPHidi4pDc7dzwim1P3gcTLZZQm+7KBByA4kKC?=
 =?us-ascii?Q?e6iR4LsQ3ShfTw080niI9JaKn7uPClqa0er3gCLS9xk8jrmqereU5TQ5M0rJ?=
 =?us-ascii?Q?hfuaxoickcJQtghbu501vPDT6d309NGisAdTnAFhrGDB8qyOzferpjlXKwW1?=
 =?us-ascii?Q?FeWnvvoD3WIMo9DLlyqsZ5AnldvAp8v+u8gbIUgEFIbg3cY3MNiagwXTMSLX?=
 =?us-ascii?Q?9JRyQu7GkRU9Ag5YT3tYlGzyXL5LR9ZQeUhQ6/RCMndSJiR4dPZWF3AUtb4o?=
 =?us-ascii?Q?41+j1UvpyUAT1thJLgYt9UVtaKX6f+cwv4HTm2qj40SnhID4Rmwy0hU9SrGL?=
 =?us-ascii?Q?qq4ZlNj8KTSYOYhPQVHNukllaJMRGBJKvd3p4cFeDSu3UYc+FpMy/bInKE6X?=
 =?us-ascii?Q?ufkroPpUO3tirjLoEKnTtXt7GkAiApbluhixcUkpwLpHRqxtfhGq1J1pt6CW?=
 =?us-ascii?Q?rVPlCBQqQoCxov2MM2PVXtIa5c8ZX7L9L295RTSIqbdz0DHmA8Trc8W5zdKL?=
 =?us-ascii?Q?qIwYyz5IrtA9ef0pM5Gdn7gP7hZTnxXn6wikU1MMM3X5eOJWjUhFUWf+etV4?=
 =?us-ascii?Q?NhadW5p1ICagrRlKbtK+Ww5E2MBVV9VUX3LKwkjcqb8wTkGLd2KbF6BiF0Oa?=
 =?us-ascii?Q?1iURTIyEGJOkB1yAOv/z0T4X010Vs9AgNqhZybwHacL0W5Z0Md1S3sfh1gj/?=
 =?us-ascii?Q?jZRdLlFNe22sudkWptuWLtcIM/Y98yqo/kzQVOrfcoMn/jBVR4sgqdlS9DVL?=
 =?us-ascii?Q?7a5n8rp7dZ209vHCct0jvgi+YSsk3nitqX4H7ggmKX5F+Z0yXr6Hw+p0Werf?=
 =?us-ascii?Q?FyeB9oTge7vxS/OmqwLsljFeJB6f+gM2qyKgFEua8q2iHz5izluMScDTdpQZ?=
 =?us-ascii?Q?aljUv68lRn2Aint5TLypwzrayCUD9OY6sOII2N963h9UnAzhgHGPuJR+qSMe?=
 =?us-ascii?Q?jFgDC4KQrkxE5aoSzhqVaVcSNZBiuYj87LYMoiP4YhxxrkMRSNDs1ky64Lmd?=
 =?us-ascii?Q?Y2fqR7l3OJZMWonnprt72GNiZaCM5yhyTCyzGthF2JbQxGXbKwleUovs4lug?=
 =?us-ascii?Q?A5IXOBRhj7gUw1Td3HNlBbnWnhY4fmc260iatuAIYrub16mp2ZSHmsZHBVBD?=
 =?us-ascii?Q?95iTfJytpKmGuMYNXkEVdD/0zMMWIg++YFqQG8wAeQQGjfd3cuqb+YPI/xFk?=
 =?us-ascii?Q?I6yM+PPGT51oKQCwRF8gDf3k3K5qW2M4O0b6VIlfE9pr1BlWxk2iYjHRWF/Y?=
 =?us-ascii?Q?JrQ5/g+Ng68kkPhgaCykv6odYRW6dNygfggTDaZ7moFzkkgo5y/zIjky+TVQ?=
 =?us-ascii?Q?T4ZgP20Czt/wnLBUa8oYZ+uhKMRMXq6HiLeraesKWvd1IQ=3D=3D?=
x-ms-exchange-transport-forked: True
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: AT5PR8401MB1059.NAMPRD84.PROD.OUTLOOK.COM
X-MS-Exchange-CrossTenant-Network-Message-Id: 2211b50a-5b73-4c23-93d9-08d8d4e1178c
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Feb 2021 14:17:29.9814 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 105b2061-b669-4b31-92ac-24d304d195dc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Xe0nneXIMlYfPgc7u4Or/NatCE9htnESIxdoqFmv4OJ5Yz8XV1CLaFScLo2iJMxRH9vQgyZasNJ2jN0vZUiFMg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AT5PR8401MB0484
X-OriginatorOrg: hpe.com
X-Proofpoint-UnRewURL: 0 URL was un-rewritten
MIME-Version: 1.0
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.369, 18.0.761
 definitions=2021-02-19_05:2021-02-18,
 2021-02-19 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 mlxlogscore=999
 malwarescore=0 priorityscore=1501 impostorscore=0 phishscore=0 mlxscore=0
 lowpriorityscore=0 clxscore=1011 suspectscore=0 spamscore=0 bulkscore=0
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2009150000 definitions=main-2102190114
Subject: Re: [lustre-devel] Testing 2.14 on Debian + ZFS
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
Content-Type: multipart/mixed; boundary="===============8541830409176400259=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8541830409176400259==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_AT5PR8401MB10590B46FE66B8103C91D04F85849AT5PR8401MB1059_"

--_000_AT5PR8401MB10590B46FE66B8103C91D04F85849AT5PR8401MB1059_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello!

>  I know this mailing list isn't used very frequently and I'd hate to floo=
d it with such off-the-beaten-path stuff.

No worries, Christian.  Any related devel topics are welcome here.  You are=
 in the right place!

-Cory

On 2/19/21, 4:11 AM, "lustre-devel" <lustre-devel-bounces@lists.lustre.org>=
 wrote:

Thanks for your time and the thoughtful response.

Looking at this a bit more, it seems to be caused by the recent ZFS 2.0 cha=
nges for linux and freebsd support, namely the `include/os/linux` paths tha=
t provide `<sys/types.h>` that ZFS is trying to use. Adding them into the i=
ncludes for the osd-zfs directory has fixed the references being broken, an=
d now I'm contending some redefinitions and argument type mismatches. I'll =
try and sort this out, in the meantime is there a better place for me to pl=
ace messages about this? I know this mailing list isn't used very frequentl=
y and I'd hate to flood it with such off-the-beaten-path stuff.

Best,
Christian

On Thu, Feb 18, 2021 at 3:09 AM Andreas Dilger <adilger@whamcloud.com<mailt=
o:adilger@whamcloud.com>> wrote:
On Feb 12, 2021, at 16:07, Christian Kuntz <c.kuntz@opendrives.com<mailto:c=
.kuntz@opendrives.com>> wrote:

Hello,

I hope I'm communicating in the right place here, I'm currently working to =
compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. If there'=
s anything I can do to help with the testing effort or help Lustre's Debian=
 support be more robust, please let me know! I hope I'm not too late in the=
 release cycle to contribute.

Thanks for the offer of testing.  Unfortunately we are very late in the 2.1=
4.0 release cycle (we are hoping to make the final release in the next week=
 or so, barring any critical defects).  However, even if any changes miss t=
he final 2.14.0 release, having patches available to fix any issues you run=
 into will make it easier for the next person to build on Debian.

Ideally, any required fixes for Debian building should go into the Lustre t=
ree directly rather than into a separate "downstream" package, so that "mak=
e debs" works out-of-the-box.  We do build Ubuntu 18.04 and 20.04 clients r=
egularly, and ZFS 2.0 servers on RHEL7/8, but I don't know if anyone is bui=
lding the server code on Debian/Ubuntu on a regular basis.


On the topic of compiling, I'm currently working to get debian packages mad=
e and running into a compilation issue that didn't seem to present on my pr=
evious endeavors with 2.13 and 0.7. I've got the kernel and zfs locally bui=
lt and their packages made, and lustre's configure step successfully comple=
tes, but when it comes to compiling it appears that the osd-zfs portion has=
 some broken include links:

In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,
                 from /lustre-debian/lustre/osd-zfs/osd_internal.h:51,
                 from /lustre-debian/lustre/osd-zfs/osd_handler.c:52:
/zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error: sys/types.h:=
 No such file or directory
 #include <sys/types.h>

For reference, my configure and make looks like:
./configure --with-linux=3D/linux-4.19.171-2/  \
             --with-linux-obj=3Dlinux-4.19.171-2/debian/build/build_amd64_n=
one_amd64 \
             --with-zfs=3D/zfs-linux-2.0.2 \
              --enable-server --enable-modules --disable-ldiskfs
make -j"$(nproc)" debs


From the error and some probing, it looks like zfs_context.h expects some h=
eader files to be in their libc standard `/usr/include/sys` (or somewhere a=
bouts), but lustre's make process is pulling them from the linux sources in=
 `SRC/include/linux/`. Predictably, I found this out the hard way by adding=
 `-I/usr/include` to the Makefile for the zfs osds and getting battered wit=
h errors and warnings about duplicate definitions.

It may be that you are looking at this from the wrong angle.  Rather than t=
rying to include more userspace headers, it might be worthwhile to see why =
<sys/arc.h> is being included by osd_internal.h and maybe there is a more a=
ppropriate header that could be used in the kernel?  Failing that, it isn't=
 clear wh zfs_context.h is including the <sys/type.h> header from userspace=
 when building with __KERNEL__ set?  Kernel code should be using <linux/typ=
es.h>.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud






--_000_AT5PR8401MB10590B46FE66B8103C91D04F85849AT5PR8401MB1059_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
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
span.EmailStyle18
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
--></style>
</head>
<body lang=3D"EN-US" link=3D"blue" vlink=3D"purple" style=3D"word-wrap:brea=
k-word">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">Hello!<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&gt; &nbsp;I know this mailing list isn't used very =
frequently and I'd hate to flood it with such off-the-beaten-path stuff.<o:=
p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">No worries, Christian.&nbsp; Any related devel topic=
s are welcome here.&nbsp; You are in the right place!<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">-Cory<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">On 2/19/21, 4:11 AM, &quo=
t;lustre-devel&quot; &lt;lustre-devel-bounces@lists.lustre.org&gt; wrote:<o=
:p></o:p></p>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Thanks for your time and =
the thoughtful response.<br>
<br>
Looking at this a bit more, it seems&nbsp;to be caused by the recent ZFS 2.=
0 changes for linux and freebsd support, namely&nbsp;the `include/os/linux`=
 paths that&nbsp;provide `&lt;sys/types.h&gt;` that ZFS is trying to use. A=
dding them into the includes for the osd-zfs directory
 has fixed the references being broken, and now I'm contending some redefin=
itions and argument type mismatches. I'll try and sort this out, in the mea=
ntime is there a better place for me to place messages about this? I know t=
his mailing list isn't used very
 frequently and I'd hate to flood it with such off-the-beaten-path stuff.<b=
r>
<br>
Best,<br>
Christian<o:p></o:p></p>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">On Thu, Feb 18, 2021 at 3=
:09 AM Andreas Dilger &lt;<a href=3D"mailto:adilger@whamcloud.com" target=
=3D"_blank">adilger@whamcloud.com</a>&gt; wrote:<o:p></o:p></p>
</div>
<blockquote style=3D"border:none;border-left:solid #CCCCCC 1.0pt;padding:0i=
n 0in 0in 6.0pt;margin-left:4.8pt;margin-right:0in">
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">On Feb 12, 2021, at 16:07=
, Christian Kuntz &lt;<a href=3D"mailto:c.kuntz@opendrives.com" target=3D"_=
blank">c.kuntz@opendrives.com</a>&gt; wrote:<o:p></o:p></p>
<div>
<blockquote style=3D"margin-top:5.0pt;margin-bottom:5.0pt">
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Hello,<br>
<br>
I hope I'm communicating in the right place here, I'm currently working to =
compile Lustre 2.14.0-RC2 on Debian 10.7 with ZFS 2.0.2 for OSDs. If there'=
s anything I can do to help with the testing effort or help Lustre's Debian=
 support be more robust, please
 let me know! I hope I'm not too late in the release cycle to contribute.&n=
bsp;<o:p></o:p></p>
</div>
</div>
</blockquote>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Thanks for the offer of t=
esting.&nbsp; Unfortunately we are very late in the 2.14.0 release cycle (w=
e are hoping to make the final release in the next week or so, barring any =
critical defects).&nbsp; However, even if any
 changes miss the final 2.14.0 release, having patches available to fix any=
 issues you run into will make it easier for the next person to build on De=
bian.<o:p></o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">Ideally, any required fix=
es for Debian building should go into the Lustre tree directly rather than =
into a separate &quot;downstream&quot; package, so that &quot;make debs&quo=
t; works out-of-the-box.&nbsp; We do build Ubuntu 18.04 and 20.04
 clients regularly, and ZFS 2.0 servers on RHEL7/8, but I don't know if any=
one is building the server code on Debian/Ubuntu on a regular basis. &nbsp;=
<o:p></o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><br>
<br>
<o:p></o:p></p>
<blockquote style=3D"margin-top:5.0pt;margin-bottom:5.0pt">
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">On the topic of compiling=
, I'm currently working to get debian packages made and running into a comp=
ilation issue that didn't seem to present on my previous endeavors with 2.1=
3 and 0.7. I've got the kernel and zfs
 locally built and their packages made, and lustre's configure step success=
fully completes, but when it comes to compiling it appears that the osd-zfs=
 portion has some broken include links:<br>
<br>
In file included from /zfs-linux-2.0.2/include/sys/arc.h:32,<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;from /lustre-=
debian/lustre/osd-zfs/osd_internal.h:51,<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;from /lustre-=
debian/lustre/osd-zfs/osd_handler.c:52:<br>
/zfs-linux-2.0.2/include/sys/zfs_context.h:45:10: fatal error: sys/types.h:=
 No such file or directory<br>
&nbsp;#include &lt;sys/types.h&gt;<br>
<br>
For reference, my configure and make looks like:<br>
./configure --with-linux=3D/linux-4.19.171-2/&nbsp; \<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;--with-linux-obj=3Dlinux-4.=
19.171-2/debian/build/build_amd64_none_amd64 \<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;--with-zfs=3D/zfs-linux-2.0=
.2 \<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; --enable-server --enable-m=
odules --disable-ldiskfs<br>
make -j&quot;$(nproc)&quot; debs<br>
<br>
<br>
From the error and some probing, it looks like zfs_context.h expects some h=
eader files to be in their libc standard `/usr/include/sys` (or somewhere a=
bouts), but lustre's make process is pulling them from the linux sources in=
 `SRC/include/linux/`. Predictably,
 I found this out the hard way by adding `-I/usr/include` to the Makefile f=
or the zfs osds and getting battered with errors and warnings about duplica=
te definitions.&nbsp;<o:p></o:p></p>
</div>
</div>
</blockquote>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in">It may be that you are lo=
oking at this from the wrong angle.&nbsp; Rather than trying to include mor=
e userspace headers, it might be worthwhile to see why &lt;sys/arc.h&gt; is=
 being included by osd_internal.h and maybe there
 is a more appropriate header that could be used in the kernel?&nbsp; Faili=
ng that, it isn't clear wh zfs_context.h is including the &lt;sys/type.h&gt=
; header from userspace when building with __KERNEL__ set?&nbsp; Kernel cod=
e should be using &lt;linux/types.h&gt;.<o:p></o:p></p>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
<div>
<div>
<div>
<div>
<div>
<div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k">Cheers, Andreas<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k">--<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k">Andreas Dilger<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k">Principal Lustre Architect<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k">Whamcloud<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k"><o:p>&nbsp;</o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k"><o:p>&nbsp;</o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><span style=3D"color:blac=
k"><o:p>&nbsp;</o:p></span></p>
</div>
</div>
</div>
</div>
</div>
</div>
<p class=3D"MsoNormal" style=3D"mso-margin-top-alt:0in;margin-right:0in;mar=
gin-bottom:12.0pt;margin-left:.5in">
<o:p>&nbsp;</o:p></p>
</div>
<p class=3D"MsoNormal" style=3D"margin-left:.5in"><o:p>&nbsp;</o:p></p>
</div>
</blockquote>
</div>
</div>
</body>
</html>

--_000_AT5PR8401MB10590B46FE66B8103C91D04F85849AT5PR8401MB1059_--

--===============8541830409176400259==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8541830409176400259==--
