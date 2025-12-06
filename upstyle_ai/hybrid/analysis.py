import subprocess
import psutil
import time
import sys
import os
from collections import deque

def format_bytes(b):
    """Return the given bytes as a human-friendly string (e.g., 100.2 MB)."""
    if b is None:
        return "N/A"
    mb = b / (1024 * 1024)
    if mb > 1024:
        return f"{mb / 1024:.2f} GB"
    return f"{mb:.2f} MB"

class ProcessAnalyzer:
    """A class to run and analyze a subprocess's resource usage."""

    def __init__(self, script_path):
        self.script_path = script_path
        self.process = None
        self.p_handle = None

        # --- Metrics Storage ---
        self.start_time = None
        self.end_time = None
        self.cpu_readings = []
        self.peak_ram_rss = 0
        self.start_io = None
        self.end_io = None

    def _print_summary(self):
        """Prints a detailed summary of the process execution."""
        duration = self.end_time - self.start_time
        avg_cpu = sum(self.cpu_readings) / len(self.cpu_readings) if self.cpu_readings else 0
        peak_cpu = max(self.cpu_readings) if self.cpu_readings else 0
        
        # Calculate I/O Delta
        read_bytes = self.end_io.read_bytes - self.start_io.read_bytes if self.start_io and self.end_io else 0
        write_bytes = self.end_io.write_bytes - self.start_io.write_bytes if self.start_io and self.end_io else 0

        print("\n\n" + "=" * 60)
        print(" " * 20 + "PERFORMANCE ANALYSIS")
        print("=" * 60)
        print(f"✅ Script Execution Complete")
        print("-" * 60)
        
        print(f"🕒 Total Execution Time: {duration:.3f} seconds")
        print("-" * 60)

        print("📊 CPU STATS:")
        print(f"   - Peak Usage:    {peak_cpu:.2f}%")
        print(f"   - Average Usage: {avg_cpu:.2f}%")

        print("\n🧠 MEMORY STATS:")
        print(f"   - Peak RAM Usage (RSS): {format_bytes(self.peak_ram_rss)}")
        
        print("\n💾 DISK I/O:")
        print(f"   - Total Data Read:    {format_bytes(read_bytes)}")
        print(f"   - Total Data Written: {format_bytes(write_bytes)}")
        
        print("=" * 60)

    def run(self):
        """Starts the subprocess and begins monitoring."""
        if not os.path.exists(self.script_path):
            print(f"❌ Error: Script not found at '{self.script_path}'")
            return

        print(f"🚀 Starting analysis for '{os.path.basename(self.script_path)}'...")
        
        try:
            self.start_time = time.time()
            self.process = subprocess.Popen(
                [sys.executable, self.script_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            self.p_handle = psutil.Process(self.process.pid)
            print(f"📊 Monitoring Process ID: {self.p_handle.pid}. Press Ctrl+C to stop.")
            
            with self.p_handle.oneshot():
                self.p_handle.cpu_percent(interval=None) # Start measurement
                self.start_io = self.p_handle.io_counters()

            self._monitor_loop()

        except KeyboardInterrupt:
            print("\n🛑 Analysis interrupted by user. Terminating process...")
            self.p_handle.terminate()
        except (psutil.NoSuchProcess, psutil.AccessDenied) as e:
            print(f"\nCould not monitor process: {e}")
        except Exception as e:
            print(f"\nAn unexpected error occurred: {e}")
        finally:
            stdout, stderr = self.process.communicate()
            print("\n--- Script Output ---")
            if stdout: print(stdout.strip())
            if stderr: print(f"--- Errors ---\n{stderr.strip()}")

            self.end_time = time.time()
            if self.p_handle and psutil.pid_exists(self.p_handle.pid):
                 self.end_io = self.p_handle.io_counters()

            if self.start_time:
                self._print_summary()

    def _monitor_loop(self):
        """The main loop to poll and display real-time stats."""
        while self.process.poll() is None:
            try:
                # IMPORTANT: Call blocking cpu_percent() BEFORE the oneshot() context
                # to ensure an accurate reading over the interval.
                cpu_usage = self.p_handle.cpu_percent(interval=1.0)

                # Now, get other stats efficiently using the cached info.
                with self.p_handle.oneshot():
                    if cpu_usage is not None:
                        self.cpu_readings.append(cpu_usage)
                    
                    memory_info = self.p_handle.memory_info()
                    ram_usage = memory_info.rss
                    if ram_usage > self.peak_ram_rss:
                        self.peak_ram_rss = ram_usage
                    
                    status = self.p_handle.status()

                # Display stats on a single, updating line
                stats_line = (
                    f"[{status.upper()}] "
                    f"CPU: {cpu_usage or 0.0:.1f}% | "
                    f"RAM: {format_bytes(ram_usage)} (Peak: {format_bytes(self.peak_ram_rss)})"
                )
                
                sys.stdout.write(f"\r{stats_line.ljust(80)}")
                sys.stdout.flush()

            except (psutil.NoSuchProcess, psutil.AccessDenied):
                break # Process ended between checks

def main():
    script_to_run = 'main.py'
    script_path = os.path.join(os.path.dirname(__file__), script_to_run)
    analyzer = ProcessAnalyzer(script_path)
    analyzer.run()

if __name__ == "__main__":
    main()