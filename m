From: LUCAS Patrice <patrice.lucas@cea.fr>
Date: Fri, 25 Jan 2008 10:45:38 +0100
Subject: [Lustre-devel] SNMP support enhancement (a quick improvement : the
 number of request per MDS)
Message-ID: <4799AFC2.7070209@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

Is Lustre team thinking about changing or improving the snmp part of the code ?

We think it could be profitable to be able to monitor Lustre client, OSS and
MDS, as any common network device by using simple snmp requests.

As an example of a quick improvement, I attached a patch that adds to
snmp-agent the feature to give the number of requests processed by an MDS node.
(This patch applies to the 1.6.2 lustre version.)

(At the same time, I submit this subject on bugzilla.lustre.org : "bug enhancement" n?14729 )

Thanks

Patrice LUCAS
CEA/DAM

-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: patch_snmp_MDSNBSAMPLEDREQ_lustre_1.6.2
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080125/428bf3a2/attachment.txt>
