From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 20 May 2018 14:42:48 +0200
Subject: [lustre-devel] [PATCH v2] staging: lustre: Change return type
 to vm_fault_t
In-Reply-To: <20180516185711.GA6587@jordon-HP-15-Notebook-PC>
References: <20180516185711.GA6587@jordon-HP-15-Notebook-PC>
Message-ID: <20180520124248.GD10031@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, May 17, 2018 at 12:27:11AM +0530, Souptick Joarder wrote:
> Use new return type vm_fault_t for fault handler. For
> now, this is just documenting that the function returns
> a VM_FAULT value rather than an errno. Once all instances
> are converted, vm_fault_t will become a distinct type.
> 
> Commit 1c8f422059ae ("mm: change return type to vm_fault_t")
> 

What does that line mean?  Please be more descriptive.

confused,

greg k-h
