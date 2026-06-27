// SnipShot — tray app. Global hotkey snips a region and puts the saved file PATH on the
// clipboard so it can be pasted into Claude Code (which can't accept a pasted image on Windows).
//
//   Ctrl+Shift+S  -> opens the snip overlay; after you draw a region, the image is saved to
//                    ~\clip-shots and the clipboard is replaced with that file's path. Ctrl+V.
//   Win+Shift+S   -> left to Windows: normal image on the clipboard (paste into a browser).
//
// Build:  csc /nologo /target:winexe /out:snipshot.exe /reference:System.Drawing.dll
//             /reference:System.Windows.Forms.dll snipshot.cs

using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Windows.Forms;

class SnipShot : ApplicationContext
{
    [DllImport("user32.dll")] static extern bool RegisterHotKey(IntPtr hWnd, int id, uint mods, uint vk);
    [DllImport("user32.dll")] static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    const int  HOTKEY_ID   = 1;
    const uint MOD_CONTROL = 0x2, MOD_SHIFT = 0x4, MOD_NOREPEAT = 0x4000;
    const uint VK_S        = 0x53;
    const int  WM_HOTKEY   = 0x0312;

    readonly NotifyIcon ni;
    readonly MsgWindow  win;
    readonly Timer      poll;
    readonly string     inbox;
    DateTime armedAt;
    string   baseHash = "";

    SnipShot()
    {
        inbox = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "clip-shots");
        Directory.CreateDirectory(inbox);

        ni = new NotifyIcon();
        ni.Icon = SystemIcons.Application;
        ni.Text = "SnipShot — Ctrl+Shift+S = snip to path";
        ni.Visible = true;
        var menu = new ContextMenuStrip();
        menu.Items.Add("Snip now (Ctrl+Shift+S)", null, (s, e) => StartSnip());
        menu.Items.Add("Open folder", null, (s, e) => { try { Process.Start(inbox); } catch { } });
        menu.Items.Add("Exit", null, (s, e) => ExitApp());
        ni.ContextMenuStrip = menu;
        ni.DoubleClick += (s, e) => StartSnip();

        win = new MsgWindow(this);
        if (!RegisterHotKey(win.Handle, HOTKEY_ID, MOD_CONTROL | MOD_SHIFT | MOD_NOREPEAT, VK_S))
            ni.ShowBalloonTip(3000, "SnipShot", "Could not register Ctrl+Shift+S (already in use).", ToolTipIcon.Warning);

        poll = new Timer();
        poll.Interval = 200;
        poll.Tick += Poll;
    }

    void StartSnip()
    {
        baseHash = CurrentClipHash();      // remember whatever is on the clipboard now
        armedAt  = DateTime.Now;
        try { Process.Start(new ProcessStartInfo("ms-screenclip:") { UseShellExecute = true }); } catch { }
        poll.Start();
    }

    void Poll(object sender, EventArgs e)
    {
        if ((DateTime.Now - armedAt).TotalSeconds > 25) { poll.Stop(); return; }   // snip cancelled
        try
        {
            if (!Clipboard.ContainsImage()) return;
            using (var img = Clipboard.GetImage())
            {
                if (img == null) return;
                byte[] bytes;
                using (var ms = new MemoryStream()) { img.Save(ms, ImageFormat.Png); bytes = ms.ToArray(); }
                string hash = Hash(bytes);
                if (hash == baseHash) return;          // still the pre-existing image; wait for the snip

                poll.Stop();
                string path = Path.Combine(inbox, "shot_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".png");
                File.WriteAllBytes(path, bytes);
                Clipboard.SetText(path);
                Trim();
                ni.ShowBalloonTip(1500, "SnipShot", "Path copied — Ctrl+V into Claude Code", ToolTipIcon.Info);
            }
        }
        catch { }   // clipboard is briefly locked while the snip tool writes; next tick retries
    }

    string CurrentClipHash()
    {
        try
        {
            if (!Clipboard.ContainsImage()) return "";
            using (var img = Clipboard.GetImage())
            {
                if (img == null) return "";
                using (var ms = new MemoryStream()) { img.Save(ms, ImageFormat.Png); return Hash(ms.ToArray()); }
            }
        }
        catch { return ""; }
    }

    static string Hash(byte[] b) { using (var md5 = MD5.Create()) return BitConverter.ToString(md5.ComputeHash(b)); }

    void Trim()   // keep the newest 20 PNGs
    {
        try
        {
            var files = new DirectoryInfo(inbox).GetFiles("*.png");
            Array.Sort(files, (a, b) => b.LastWriteTime.CompareTo(a.LastWriteTime));
            for (int i = 20; i < files.Length; i++) { try { files[i].Delete(); } catch { } }
        }
        catch { }
    }

    public void OnHotkey() { StartSnip(); }

    void ExitApp()
    {
        try { UnregisterHotKey(win.Handle, HOTKEY_ID); } catch { }
        poll.Stop();
        ni.Visible = false;
        ni.Dispose();
        ExitThread();
    }

    class MsgWindow : NativeWindow
    {
        readonly SnipShot app;
        public MsgWindow(SnipShot a) { app = a; CreateHandle(new CreateParams()); }
        protected override void WndProc(ref Message m)
        {
            if (m.Msg == WM_HOTKEY) app.OnHotkey();
            base.WndProc(ref m);
        }
    }

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.Run(new SnipShot());
    }
}
