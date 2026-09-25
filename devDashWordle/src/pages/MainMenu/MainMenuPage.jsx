export default function MainMenu() {
  return (
    <main className= "min-h-screen bg-black p-6">
      
      <div className = "flex w-full items-start gap-2">
        <div className= "w-full max-w-xl top-0 left-0 rounded-2xl bg-grey p-8 shadow-md">
          <h1 className= "bottom-0 text-3xl font-bold text-white mb-3">Dev Games</h1> 
        </div> 

        <div className = " w-200 h-200 p-1">
          <img className = " right-0 top-0 aspect-square w-40 h-40 object-cover" src = "/src/assets/vite.svg" alt = "temp logo placement"></img>
        </div>

      </div>

    </main>
  );
}