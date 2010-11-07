From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Sun, 7 Nov 2010 18:43:24 -0500
Subject: [Lustre-devel] Lustre RPC related information
Message-ID: <AANLkTik96oNGfaK5sPaLcuWO=pUTN9gs9+ynN6=V4mgU@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

Amongst all these RPC which all are for lock related request and which do
not ask for locks .E.g OBD_PING does not asks for locks where as
LDLM_ENQUEUE is the main entry point for handling lock related request.It
would also be great if you can tell me with which system call which RPC
might be invoked.Thanks.


MDS_CONNECT
MDS_DISCONNECT
MDS_GETSTATUS
MDS_GETATTR
MDS_SETXATTR
MDS_GETXATTR
MDS_GETATTR_NAME
MDS_STATFS
MDS_READPAGE
MDS_REINT
MDS_CLOSE
MDS_DONE_WRITING
MDS_PIN

MDS_SYNC
MDS_SET_INFO
MDS_QUOTACHECK
MDS_QUOTACTL
MDS_GETXATTR
MDS_SETXATTR
MDS_WRITEPAGE
MDS_IS_SUBDIR


OBD_PING
OBD_LOG_CANCEL
OBD_QC_CALLBACK

LDLM_ENQUEUE
LDLM_CONVERT
LDLM_CANCEL
LDLM_BL_CALLBACK
LDLM_CP_CALLBACK
LDLM_GL_CALLBACK




Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101107/39c6ac93/attachment.htm>
